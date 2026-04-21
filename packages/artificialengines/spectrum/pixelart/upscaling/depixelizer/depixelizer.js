/* TypeScript API:
type Image = {
  data: Buffer; // Or Uint8Array - pixels in RGBA byte order
  width: number;
  height: number;
  similarityData?: Buffer;
};

type Opts = {
  height: number;
  threshold?: number; // 0..255, lower = fewer similarity edges
  borderPx?: number; // pad input with this many pixels (1-2)
  similarity?: Buffer; // if specified uses values here instead or RGBA values to determine similarity - threshold (default 3) is used against sum of RGB differences
  outputSimilarityMask?: boolean; // if this and similarity are specified, return similarityData
  renderMode?: 'splines' |  'default';
  doOpt?: boolean; // default true
}

function scaleImage(src: Image, opts: Opts): Image;
*/

const {
  abs,
  ceil,
  exp,
  floor,
  hypot,
  max,
  min,
  round,
  sign,
} = Math;

const EDGE_HORVERT = 16;
const EDGE_DIAGONAL_ULLR = 32;
const EDGE_DIAGONAL_LLUR = 64;

const HAS_NORTHERN_NEIGHBOR = 1;
const HAS_EASTERN_NEIGHBOR = 2;
const HAS_SOUTHERN_NEIGHBOR = 4;
const HAS_WESTERN_NEIGHBOR = 8;
const HAS_NORTHERN_SPLINE = 16;
const HAS_EASTERN_SPLINE = 32;
const HAS_SOUTHERN_SPLINE = 64;
const HAS_WESTERN_SPLINE = 128;
const HAS_CORRECTED_POSITION = 256;
const DONT_OPTIMIZE_N = 512;
const DONT_OPTIMIZE_E = 1024;
const DONT_OPTIMIZE_S = 2048;
const DONT_OPTIMIZE_W = 4096;

const NORTH = 128;
const NORTHEAST = 64;
const EAST = 32;
const SOUTHEAST = 16;
const SOUTH = 8;
const SOUTHWEST = 4;
const WEST = 2;
const NORTHWEST = 1;

const STEP = 0.2;
const GAUSS_MULTIPLIER = 2.5;

const POSITIONAL_ENERGY_SCALING = 2.5;

const LIMIT_SEARCH_ITERATIONS = 20.0;
const R = 0.61803399;
const C = 1 - R;
const TOL = 0.0001;
const BRACKET_SEARCH_A = 0.1;
const BRACKET_SEARCH_B = -0.1;
const GOLD = 1.618034;
const GLIMIT = 10.0;
const TINY = 0.000000001;
const ONEo255 = 1/255;

function clampInt(v, lo, hi) {
  if (v < lo) {
    return lo;
  }
  if (v > hi) {
    return hi;
  }
  return v;
}

function pixelIndex(x, y, w) {
  return (y * w + x) * 4;
}

function fetchPixelRGBA(src, x, y) {
  const w = src.width;
  const h = src.height;
  const cx = clampInt(x, 0, w - 1);
  const cy = clampInt(y, 0, h - 1);
  const idx = pixelIndex(cx, cy, w);
  const d = src.data;
  return [d[idx] * ONEo255, d[idx + 1] * ONEo255, d[idx + 2] * ONEo255, d[idx + 3] * ONEo255];
}

function fetchPixelRGBA8(src, x, y) {
  const w = src.width;
  const h = src.height;
  const cx = clampInt(x, 0, w - 1);
  const cy = clampInt(y, 0, h - 1);
  const idx = pixelIndex(cx, cy, w);
  const d = src.data;
  return [d[idx], d[idx + 1], d[idx + 2], d[idx + 3]];
}

const THRESHOLD_a = 32 / 255;
const THRESHOLD_y = 48 / 255;
const THRESHOLD_u = 7 / 255;
const THRESHOLD_v = 6 / 255;
function isSimilar(a, b, threshold) {
  const yA = 0.299 * a[0] + 0.587 * a[1] + 0.114 * a[2];
  const uA = 0.493 * (a[2] - yA);
  const vA = 0.877 * (a[0] - yA);
  const yB = 0.299 * b[0] + 0.587 * b[1] + 0.114 * b[2];
  const uB = 0.493 * (b[2] - yB);
  const vB = 0.877 * (b[0] - yB);
  if (abs(a[3] - b[3]) <= THRESHOLD_a * threshold) {
    if (a[3] + b[3] <= THRESHOLD_a * threshold) {
      // treat all alpha=0 pixels as similar, regardless of color
      // note: need an option for this if processing images with masks or premultiplied alpha
      return true;
    }
    if (abs(yA - yB) <= THRESHOLD_y * threshold) {
      if (abs(uA - uB) <= THRESHOLD_u * threshold) {
        if (abs(vA - vB) <= THRESHOLD_v * threshold) {
          return true;
        }
      }
    }
  }
  return false;
}

const THRESHOLD_CONTOUR = 100 / 255;
const THRESHOLD_CONTOUR_SQ = THRESHOLD_CONTOUR * THRESHOLD_CONTOUR;
function isContour(src, pL, pR) {
  const a = fetchPixelRGBA(src, pL[0], pL[1]);
  const b = fetchPixelRGBA(src, pR[0], pR[1]);
  const yA = 0.299 * a[0] + 0.587 * a[1] + 0.114 * a[2];
  const uA = 0.493 * (a[2] - yA);
  const vA = 0.877 * (a[0] - yA);
  const yB = 0.299 * b[0] + 0.587 * b[1] + 0.114 * b[2];
  const uB = 0.493 * (b[2] - yB);
  const vB = 0.877 * (b[0] - yB);
  const dy = yA - yB;
  const du = uA - uB;
  const dv = vA - vB;
  const dist_sq = dy * dy + du * du + dv * dv;
  return dist_sq > THRESHOLD_CONTOUR_SQ;
}

function buildSimilarityGraph(src, similarityThreshold, similarity) {
  const w = src.width;
  const h = src.height;
  const sgW = 2 * w + 1;
  const sgH = 2 * h + 1;
  const r = new Int32Array(sgW * sgH);
  const g = new Int32Array(sgW * sgH);

  function setRG(x, y, rv, gv) {
    const idx = y * sgW + x;
    r[idx] = rv | 0;
    g[idx] = gv | 0;
  }

  function getPixelCoords(gx, gy) {
    return [floor((gx - 1) / 2), floor((gy - 1) / 2)];
  }

  let isSimilar2;
  if (similarity) {
    let simImage = {
      ...src,
      data: similarity,
    };
    isSimilar2 = function(p1, p2) {
      let v1 = fetchPixelRGBA8(simImage, p1[0], p1[1]);
      let v2 = fetchPixelRGBA8(simImage, p2[0], p2[1]);
      let sum = abs(v1[0] - v2[0]) + abs(v1[1] - v2[1]) + abs(v1[2] - v2[2]);
      return sum <= similarityThreshold;
    }
  } else {
    isSimilar2 = function(p1, p2) {
      return isSimilar(fetchPixelRGBA(src, p1[0], p1[1]), fetchPixelRGBA(src, p2[0], p2[1]), similarityThreshold);
    }
  }

  for (let y = 0; y < sgH; y++) {
    for (let x = 0; x < sgW; x++) {
      if (x === 0 || x === sgW - 1 || y === 0 || y === sgH - 1) {
        setRG(x, y, 0, 0);
        continue;
      }
      const evalX = x & 1;
      const evalY = y & 1;
      if (evalX === 1 && evalY === 1) {
        setRG(x, y, 0, 0);
      } else if (evalX === 0 && evalY === 0) {
        let diagonal = 0;
        let pA = getPixelCoords(x - 1, y + 1);
        let pB = getPixelCoords(x + 1, y - 1);
        if (isSimilar2(pA, pB)) {
          diagonal = EDGE_DIAGONAL_ULLR;
        }
        pA = getPixelCoords(x - 1, y - 1);
        pB = getPixelCoords(x + 1, y + 1);
        if (isSimilar2(pA, pB)) {
          diagonal |= EDGE_DIAGONAL_LLUR;
        }
        setRG(x, y, diagonal, 0);
      } else if (evalX === 0 && evalY === 1) {
        const pA = getPixelCoords(x - 1, y);
        const pB = getPixelCoords(x + 1, y);
        if (isSimilar2(pA, pB)) {
          setRG(x, y, EDGE_HORVERT, 0);
        } else {
          setRG(x, y, 0, 0);
        }
      } else if (evalX === 1 && evalY === 0) {
        const pA = getPixelCoords(x, y - 1);
        const pB = getPixelCoords(x, y + 1);
        if (isSimilar2(pA, pB)) {
          setRG(x, y, EDGE_HORVERT, 0);
        } else {
          setRG(x, y, 0, 0);
        }
      } else {
        setRG(x, y, 0, 0);
      }
    }
  }

  return { r, g, w: sgW, h: sgH };
}

function valenceUpdate(sim) {
  const sgW = sim.w;
  const sgH = sim.h;
  const rIn = sim.r;
  const gIn = sim.g;
  const rOut = new Int32Array(sgW * sgH);
  const gOut = new Int32Array(sgW * sgH);

  function getR(x, y) {
    if (x < 0 || y < 0 || x >= sgW || y >= sgH) {
      return 0;
    }
    return rIn[y * sgW + x] | 0;
  }

  for (let y = 0; y < sgH; y++) {
    for (let x = 0; x < sgW; x++) {
      const idx = y * sgW + x;
      if (x === 0 || x === sgW - 1 || y === 0 || y === sgH - 1) {
        rOut[idx] = 0;
        gOut[idx] = 0;
        continue;
      }
      const evalX = x & 1;
      const evalY = y & 1;
      if (evalX === 1 && evalY === 1) {
        let valence = 0;
        let edges = 0;
        let edgeValue = getR(x - 1, y + 1);
        if ((edgeValue & EDGE_DIAGONAL_ULLR) === EDGE_DIAGONAL_ULLR) {
          valence++;
          edges |= NORTHWEST;
        }
        if (getR(x, y + 1) > 0) {
          valence++;
          edges |= NORTH;
        }
        edgeValue = getR(x + 1, y + 1);
        if ((edgeValue & EDGE_DIAGONAL_LLUR) === EDGE_DIAGONAL_LLUR) {
          valence++;
          edges |= NORTHEAST;
        }
        if (getR(x + 1, y) > 0) {
          valence++;
          edges |= EAST;
        }
        edgeValue = getR(x + 1, y - 1);
        if ((edgeValue & EDGE_DIAGONAL_ULLR) === EDGE_DIAGONAL_ULLR) {
          valence++;
          edges |= SOUTHEAST;
        }
        if (getR(x, y - 1) > 0) {
          valence++;
          edges |= SOUTH;
        }
        edgeValue = getR(x - 1, y - 1);
        if ((edgeValue & EDGE_DIAGONAL_LLUR) === EDGE_DIAGONAL_LLUR) {
          valence++;
          edges |= SOUTHWEST;
        }
        if (getR(x - 1, y) > 0) {
          valence++;
          edges |= WEST;
        }
        rOut[idx] = valence;
        gOut[idx] = edges;
      } else {
        rOut[idx] = rIn[idx];
        gOut[idx] = gIn[idx];
      }
    }
  }
  return { r: rOut, g: gOut, w: sgW, h: sgH };
}

function eliminateCrossings(sim) {
  const sgW = sim.w;
  const sgH = sim.h;
  const rIn = sim.r;
  const gIn = sim.g;
  const rOut = new Int32Array(sgW * sgH);
  const gOut = new Int32Array(sgW * sgH);

  function getR(x, y) {
    if (x < 0 || y < 0 || x >= sgW || y >= sgH) {
      return 0;
    }
    return rIn[y * sgW + x] | 0;
  }
  function getG(x, y) {
    if (x < 0 || y < 0 || x >= sgW || y >= sgH) {
      return 0;
    }
    return gIn[y * sgW + x] | 0;
  }
  function setRG(x, y, rv, gv) {
    const idx = y * sgW + x;
    rOut[idx] = rv | 0;
    gOut[idx] = gv | 0;
  }

  for (let y = 0; y < sgH; y++) {
    for (let x = 0; x < sgW; x++) {
      const fragmentValue = getR(x, y);

      let voteA = 0;
      let voteB = 0;
      let componentSizeA = 2;
      let componentSizeB = 2;

      function countForComponent(c) {
        if (c === 1) {
          componentSizeA++;
        } else if (c === 2) {
          componentSizeB++;
        }
      }

      function voteIslands() {
        if (getR(x - 1, y + 1) === 1) {
          voteA += 5;
          return;
        }
        if (getR(x + 1, y - 1) === 1) {
          voteA += 5;
          return;
        }
        if (getR(x - 1, y - 1) === 1) {
          voteB += 5;
          return;
        }
        if (getR(x + 1, y + 1) === 1) {
          voteB += 5;
          return; // eslint-disable-line no-useless-return
        }
      }

      function voteSparsePixels() {
        const lArray = new Int32Array([
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,1,2,0,0,0,
          0,0,0,2,1,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0
        ]);

        let nNW = 0;
        let nW = 0;
        let nSW = 0;
        let nS = 0;
        let nSE = 0;
        let nE = 0;
        let nNE = 0;
        let nN = 0;
        for (let level = 0; level < 2; level++) {
          let xOFFSET = -(1 + 2 * level);
          let yOFFSET = 1 + (2 * level);
          let nhood = getG(x + xOFFSET, y + yOFFSET);
          let currentComponentIndex = 8 * (3 - level) + (3 - level);
          let currentComponent = lArray[currentComponentIndex];
          nS  = 8 * (4 - level) + (3 - level);
          nSW = 8 * (4 - level) + (2 - level);
          nW  = 8 * (3 - level) + (2 - level);
          nNW = 8 * (2 - level) + (2 - level);
          nN  = 8 * (2 - level) + (3 - level);
          nNE = 8 * (2 - level) + (4 - level);
          nE  = 8 * (3 - level) + (4 - level);
          if (currentComponent === 0) {
            if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHWEST) && (lArray[nSW] !== 0)) { currentComponent = lArray[nSW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHWEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nNW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHEAST) && (lArray[nNE] !== 0)) { currentComponent = lArray[nNE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
          }
          if (currentComponent !== 0) {
            if (nhood & SOUTHWEST) { if (lArray[nSW] === 0) { lArray[nSW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & WEST) { if (lArray[nW] === 0) { lArray[nW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTHWEST) { if (lArray[nNW] === 0) { lArray[nNW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTH) { if (lArray[nN] === 0) { lArray[nN] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTHEAST) { if (lArray[nNE] === 0) { lArray[nNE] = currentComponent; countForComponent(currentComponent); } }
          }
          if (level > 0) {
            for (let i = 0; i < level * 2; i++) {
              xOFFSET = -(2 * level - 1) + 2 * i;
              yOFFSET = 1 + 2 * level;
              nhood = getG(x + xOFFSET, y + yOFFSET);
              currentComponentIndex = 8 * (3 - level) + (i + 4 - level);
              currentComponent = lArray[currentComponentIndex];
              nW  = 8 * (3 - level) + (i + 3 - level);
              nNW = 8 * (2 - level) + (i + 3 - level);
              nN  = 8 * (2 - level) + (i + 4 - level);
              nNE = 8 * (2 - level) + (i + 5 - level);
              nE  = 8 * (3 - level) + (i + 5 - level);
              if (currentComponent === 0) {
                if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & NORTHWEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nNW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & NORTHEAST) && (lArray[nNE] !== 0)) { currentComponent = lArray[nNE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
              }
              if (currentComponent !== 0) {
                if (nhood & NORTHWEST) { if (lArray[nNW] === 0) { lArray[nNW] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & NORTH) { if (lArray[nN] === 0) { lArray[nN] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & NORTHEAST) { if (lArray[nNE] === 0) { lArray[nNE] = currentComponent; countForComponent(currentComponent); } }
              }
            }
          }

          xOFFSET = (1 + 2 * level);
          yOFFSET = 1 + (2 * level);
          nhood = getG(x + xOFFSET, y + yOFFSET);
          currentComponentIndex = 8 * (3 - level) + (4 + level);
          currentComponent = lArray[currentComponentIndex];
          nW  = 8 * (3 - level) + (3 + level);
          nNW = 8 * (2 - level) + (3 + level);
          nN  = 8 * (2 - level) + (4 + level);
          nNE = 8 * (2 - level) + (5 + level);
          nE  = 8 * (3 - level) + (5 + level);
          nSE = 8 * (4 - level) + (5 + level);
          nS  = 8 * (4 - level) + (4 + level);
          if (currentComponent === 0) {
            if ((nhood & WEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHWEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nNW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHEAST) && (lArray[nNE] !== 0)) { currentComponent = lArray[nNE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHEAST) && (lArray[nSE] !== 0)) { currentComponent = lArray[nSE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
          }
          if (currentComponent !== 0) {
            if (nhood & NORTHWEST) { if (lArray[nNW] === 0) { lArray[nNW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTH) { if (lArray[nN] === 0) { lArray[nN] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTHEAST) { if (lArray[nNE] === 0) { lArray[nNE] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & EAST) { if (lArray[nE] === 0) { lArray[nE] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTHEAST) { if (lArray[nSE] === 0) { lArray[nSE] = currentComponent; countForComponent(currentComponent); } }
          }
          if (level > 0) {
            for (let i = 0; i < level * 2; i++) {
              xOFFSET = 1 + 2 * level;
              yOFFSET = 2 * level - 1 - 2 * i;
              nhood = getG(x + xOFFSET, y + yOFFSET);
              currentComponentIndex = 8 * (i + 4 - level) + (4 + level);
              currentComponent = lArray[currentComponentIndex];
              nN = 8 * (i + 3 - level) + (4 + level);
              nNE = 8 * (i + 3 - level) + (5 + level);
              nE = 8 * (i + 4 - level) + (5 + level);
              nSE = 8 * (i + 5 - level) + (5 + level);
              nS = 8 * (i + 5 - level) + (4 + level);
              if (currentComponent === 0) {
                if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & NORTHEAST) && (lArray[nNE] !== 0)) { currentComponent = lArray[nNE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTHEAST) && (lArray[nSE] !== 0)) { currentComponent = lArray[nSE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
              }
              if (currentComponent !== 0) {
                if (nhood & NORTHEAST) { if (lArray[nNE] === 0) { lArray[nNE] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & EAST) { if (lArray[nE] === 0) { lArray[nE] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTHEAST) { if (lArray[nSE] === 0) { lArray[nSE] = currentComponent; countForComponent(currentComponent); } }
              }
            }
          }

          xOFFSET = (1 + 2 * level);
          yOFFSET = -(1 + 2 * level);
          nhood = getG(x + xOFFSET, y + yOFFSET);
          currentComponentIndex = 8 * (4 + level) + (4 + level);
          currentComponent = lArray[currentComponentIndex];
          nN = 8 * (3 + level) + (4 + level);
          nNE = 8 * (3 + level) + (5 + level);
          nE = 8 * (4 + level) + (5 + level);
          nSE = 8 * (5 + level) + (5 + level);
          nS = 8 * (5 + level) + (4 + level);
          nSW = 8 * (5 + level) + (3 + level);
          nW = 8 * (4 + level) + (3 + level);
          if (currentComponent === 0) {
            if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHEAST) && (lArray[nNE] !== 0)) { currentComponent = lArray[nNE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHEAST) && (lArray[nSE] !== 0)) { currentComponent = lArray[nSE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHWEST) && (lArray[nSW] !== 0)) { currentComponent = lArray[nSW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
          }
          if (currentComponent !== 0) {
            if (nhood & NORTHEAST) { if (lArray[nNE] === 0) { lArray[nNE] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & EAST) { if (lArray[nE] === 0) { lArray[nE] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTHEAST) { if (lArray[nSE] === 0) { lArray[nSE] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTH) { if (lArray[nS] === 0) { lArray[nS] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTHWEST) { if (lArray[nSW] === 0) { lArray[nSW] = currentComponent; countForComponent(currentComponent); } }
          }

          if (level > 0) {
            for (let i = 0; i < level * 2; i++) {
              xOFFSET = -(2 * level - 1) + 2 * i;
              yOFFSET = -(1 + 2 * level);
              nhood = getG(x + xOFFSET, y + yOFFSET);
              currentComponentIndex = 8 * (4 + level) + (i + 4 - level);
              currentComponent = lArray[currentComponentIndex];
              nE = 8 * (4 + level) + (i + 5 - level);
              nSE = 8 * (5 + level) + (i + 5 - level);
              nS = 8 * (5 + level) + (i + 4 - level);
              nSW = 8 * (5 + level) + (i + 3 - level);
              nW = 8 * (4 + level) + (i + 3 - level);
              if (currentComponent === 0) {
                if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTHEAST) && (lArray[nSE] !== 0)) { currentComponent = lArray[nSE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTHWEST) && (lArray[nSW] !== 0)) { currentComponent = lArray[nSW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
              }
              if (currentComponent !== 0) {
                if (nhood & EAST) { if (lArray[nE] === 0) { lArray[nE] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTHEAST) { if (lArray[nSE] === 0) { lArray[nSE] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTH) { if (lArray[nS] === 0) { lArray[nS] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTHWEST) { if (lArray[nSW] === 0) { lArray[nSW] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & WEST) { if (lArray[nW] === 0) { lArray[nW] = currentComponent; countForComponent(currentComponent); } }
              }
            }
          }

          xOFFSET = -(1 + 2 * level);
          yOFFSET = -(1 + 2 * level);
          nhood = getG(x + xOFFSET, y + yOFFSET);
          currentComponentIndex = 8 * (4 + level) + (3 - level);
          currentComponent = lArray[currentComponentIndex];
          nN = 8 * (3 + level) + (3 - level);
          nNW = 8 * (3 + level) + (2 - level);
          nW = 8 * (4 + level) + (2 - level);
          nSW = 8 * (5 + level) + (2 - level);
          nS = 8 * (5 + level) + (3 - level);
          nSE = 8 * (5 + level) + (4 - level);
          nE = 8 * (4 + level) + (4 - level);
          if (currentComponent === 0) {
            if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & NORTHWEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nNW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHWEST) && (lArray[nSW] !== 0)) { currentComponent = lArray[nSW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & SOUTHEAST) && (lArray[nSE] !== 0)) { currentComponent = lArray[nSE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
            else if ((nhood & EAST) && (lArray[nE] !== 0)) { currentComponent = lArray[nE]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
          }
          if (currentComponent !== 0) {
            if (nhood & NORTH) { if (lArray[nN] === 0) { lArray[nN] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & NORTHWEST) { if (lArray[nNW] === 0) { lArray[nNW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & WEST) { if (lArray[nW] === 0) { lArray[nW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTHWEST) { if (lArray[nSW] === 0) { lArray[nSW] = currentComponent; countForComponent(currentComponent); } }
            if (nhood & SOUTH) { if (lArray[nS] === 0) { lArray[nS] = currentComponent; countForComponent(currentComponent); } }
          }

          if (level > 0) {
            for (let i = 0; i < level * 2; i++) {
              xOFFSET = -(1 + 2 * level);
              yOFFSET = 2 * level - 1 - 2 * i;
              nhood = getG(x + xOFFSET, y + yOFFSET);
              currentComponentIndex = 8 * (i + 4 - level) + (3 - level);
              currentComponent = lArray[currentComponentIndex];
              nN = 8 * (i + 3 - level) + (3 - level);
              nNW = 8 * (i + 3 - level) + (2 - level);
              nW = 8 * (i + 4 - level) + (2 - level);
              nSW = 8 * (i + 5 - level) + (2 - level);
              nS = 8 * (i + 5 - level) + (3 - level);
              if (currentComponent === 0) {
                if ((nhood & NORTH) && (lArray[nN] !== 0)) { currentComponent = lArray[nN]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & NORTHWEST) && (lArray[nNW] !== 0)) { currentComponent = lArray[nNW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & WEST) && (lArray[nW] !== 0)) { currentComponent = lArray[nW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTHWEST) && (lArray[nSW] !== 0)) { currentComponent = lArray[nSW]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
                else if ((nhood & SOUTH) && (lArray[nS] !== 0)) { currentComponent = lArray[nS]; lArray[currentComponentIndex] = currentComponent; countForComponent(currentComponent); }
              }
              if (currentComponent !== 0) {
                if (nhood & NORTH) { if (lArray[nN] === 0) { lArray[nN] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & NORTHWEST) { if (lArray[nNW] === 0) { lArray[nNW] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & WEST) { if (lArray[nW] === 0) { lArray[nW] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTHWEST) { if (lArray[nSW] === 0) { lArray[nSW] = currentComponent; countForComponent(currentComponent); } }
                if (nhood & SOUTH) { if (lArray[nS] === 0) { lArray[nS] = currentComponent; countForComponent(currentComponent); } }
              }
            }
          }
        }

        if (componentSizeA < componentSizeB) {
          voteA += (componentSizeB - componentSizeA);
        } else if (componentSizeA > componentSizeB) {
          voteB += (componentSizeA - componentSizeB);
        }
      }

      function traceNodes(nodeCoords, predecessorNodeDirection) {
        let totalLength = 0;
        let currentNodeCoords = nodeCoords.slice();
        let currentNodeValueX = getR(currentNodeCoords[0], currentNodeCoords[1]);
        let currentNodeValueY = getG(currentNodeCoords[0], currentNodeCoords[1]);
        let nextNodeCoords = [0, 0];
        let directionToCurrentNode = 0;
        while (currentNodeValueX === 2) {
          const nextNodeDirection = currentNodeValueY ^ predecessorNodeDirection;
          switch (nextNodeDirection) {
            case 1: nextNodeCoords = [currentNodeCoords[0] - 1, currentNodeCoords[1] + 1]; directionToCurrentNode = 16; break;
            case 2: nextNodeCoords = [currentNodeCoords[0] - 1, currentNodeCoords[1]]; directionToCurrentNode = 32; break;
            case 4: nextNodeCoords = [currentNodeCoords[0] - 1, currentNodeCoords[1] - 1]; directionToCurrentNode = 64; break;
            case 8: nextNodeCoords = [currentNodeCoords[0], currentNodeCoords[1] - 1]; directionToCurrentNode = 128; break;
            case 16: nextNodeCoords = [currentNodeCoords[0] + 1, currentNodeCoords[1] - 1]; directionToCurrentNode = 1; break;
            case 32: nextNodeCoords = [currentNodeCoords[0] + 1, currentNodeCoords[1]]; directionToCurrentNode = 2; break;
            case 64: nextNodeCoords = [currentNodeCoords[0] + 1, currentNodeCoords[1] + 1]; directionToCurrentNode = 4; break;
            case 128: nextNodeCoords = [currentNodeCoords[0], currentNodeCoords[1] + 1]; directionToCurrentNode = 8; break;
            default: directionToCurrentNode = predecessorNodeDirection; nextNodeCoords = currentNodeCoords; return 0;
          }
          currentNodeCoords = nextNodeCoords;
          predecessorNodeDirection = directionToCurrentNode;
          currentNodeValueX = getR(currentNodeCoords[0], currentNodeCoords[1]);
          currentNodeValueY = getG(currentNodeCoords[0], currentNodeCoords[1]);
          totalLength++;
        }
        return totalLength;
      }

      function voteCurves() {
        let lengthA = 1;
        let lengthB = 1;
        const A1 = [x - 1, y + 1];
        const A2 = [x + 1, y - 1];
        const B1 = [x - 1, y - 1];
        const B2 = [x + 1, y + 1];
        lengthA += traceNodes(A1, 16);
        lengthA += traceNodes(A2, 1);
        lengthB += traceNodes(B1, 64);
        lengthB += traceNodes(B2, 4);
        if (lengthA === lengthB) {
          return;
        }
        if (lengthA > lengthB) {
          voteA += (lengthA - lengthB);
        } else {
          voteB += (lengthB - lengthA);
        }
      }

      function isFullyConnectedCD() {
        return getR(x, y + 1) !== 0;
      }

      function isFullyConnectedD() {
        if (getR(x, y + 1) === EDGE_HORVERT) {
          if (getR(x + 1, y) === EDGE_HORVERT) {
            if (getR(x, y - 1) === EDGE_HORVERT) {
              if (getR(x - 1, y) === EDGE_HORVERT) {
                return true;
              }
            }
          }
        }
        return false;
      }

      if (fragmentValue === 96) {
        if (isFullyConnectedCD()) {
          setRG(x, y, 0, 0);
          continue;
        }
        voteCurves();
        voteIslands();
        voteSparsePixels();
        if (voteA === voteB) {
          setRG(x, y, 0, 0);
        } else if (voteA > voteB) {
          setRG(x, y, EDGE_DIAGONAL_ULLR, 0);
        } else {
          setRG(x, y, EDGE_DIAGONAL_LLUR, 0);
        }
      } else if (fragmentValue === EDGE_DIAGONAL_ULLR || fragmentValue === EDGE_DIAGONAL_LLUR) {
        if (isFullyConnectedD()) {
          setRG(x, y, 0, 0);
        } else {
          setRG(x, y, fragmentValue, getG(x, y));
        }
      } else {
        setRG(x, y, fragmentValue, getG(x, y));
      }
    }
  }

  return { r: rOut, g: gOut, w: sgW, h: sgH };
}

function computeCellGraph(src, sim) {
  const w = src.width;
  const h = src.height;
  const dy = w - 1;
  const count = (w - 1) * (h - 1) * 2;
  const pos = new Float32Array(count * 2);
  const neighbors = new Int32Array(count * 4);
  const flags = new Int32Array(count);

  function getSimR(x, y) {
    if (x < 0 || y < 0 || x >= sim.w || y >= sim.h) {
      return 0;
    }
    return sim.r[y * sim.w + x] | 0;
  }

  function getNeighborIndex(cx, cy, dir, targetSector) {
    let index = -1;
    if (dir === 'N') {
      index = ((cy + 1) * dy + cx) * 2 + targetSector;
    } else if (dir === 'E') {
      index = (cy * dy + cx + 1) * 2 + targetSector;
    } else if (dir === 'S') {
      index = ((cy - 1) * dy + cx) * 2 + targetSector;
    } else if (dir === 'W') {
      index = (cy * dy + cx - 1) * 2 + targetSector;
    } else if (dir === 'C') {
      index = (cy * dy + cx) * 2 + targetSector;
    }
    return index;
  }

  function calcAdjustedPoint(p0, p1, p2) {
    return [0.125 * p0[0] + 0.75 * p1[0] + 0.125 * p2[0], 0.125 * p0[1] + 0.75 * p1[1] + 0.125 * p2[1]];
  }

  function checkForCorner(s1, s2) {
    const n1 = hypot(s1[0], s1[1]);
    const n2 = hypot(s2[0], s2[1]);
    if (n1 === 0 || n2 === 0) {
      return false;
    }
    const dp = (s1[0] / n1) * (s2[0] / n2) + (s1[1] / n1) * (s2[1] / n2);
    if (dp > -0.7072 && dp < -0.7070) {
      return true;
    }
    if (dp > -0.3163 && dp < -0.3161) {
      return true;
    }
    if (dp > -0.0001 && dp < 0.0001) {
      return true;
    }
    return false;
  }

  for (let cy = 0; cy < h - 1; cy++) {
    for (let cx = 0; cx < w - 1; cx++) {
      const simX = cx * 2 + 2;
      const simY = cy * 2 + 2;
      const eCenter = getSimR(simX, simY);
      const eNorth = getSimR(simX, simY + 1);
      const eNorthCenter = getSimR(simX, simY + 2);
      const eEast = getSimR(simX + 1, simY);
      const eEastCenter = getSimR(simX + 2, simY);
      const eSouth = getSimR(simX, simY - 1);
      const eSouthCenter = getSimR(simX, simY - 2);
      const eWest = getSimR(simX - 1, simY);
      const eWestCenter = getSimR(simX - 2, simY);

      let v0_pos = [-1, -1];
      let v1_pos = [-1, -1];
      let v0_neighbors = [-1, -1, -1, -1];
      let v1_neighbors = [-1, -1, -1, -1];
      let v0_flags = 0;
      let v1_flags = 0;

      let ignoreN = false;
      let ignoreE = false;
      let ignoreS = false;
      let ignoreW = false;
      if (cy > h - 3) {
        ignoreN = true;
      }
      if (cx > w - 3) {
        ignoreE = true;
      }
      if (cy < 1) {
        ignoreS = true;
      }
      if (cx < 1) {
        ignoreW = true;
      }

      let neighborsFound = false;
      let nNeighborsFound = false;
      let wNeighborsFound = false;
      let sNeighborsFound = false;
      let eNeighborsFound = false;
      let neighborCount = 0;
      let nNeighborIndex = -1;
      let wNeighborIndex = -1;
      let sNeighborIndex = -1;
      let eNeighborIndex = -1;

      let nVector = [0, 0];
      let eVector = [0, 0];
      let sVector = [0, 0];
      let wVector = [0, 0];

      if (!ignoreN && eNorth === 0) {
        nNeighborsFound = true;
        neighborsFound = true;
        neighborCount++;
        if (eNorthCenter === EDGE_DIAGONAL_ULLR) {
          nNeighborIndex = getNeighborIndex(cx, cy, 'N', 0);
          nVector = [-0.25, 0.75];
        } else if (eNorthCenter === EDGE_DIAGONAL_LLUR) {
          nNeighborIndex = getNeighborIndex(cx, cy, 'N', 1);
          nVector = [0.25, 0.75];
        } else {
          nNeighborIndex = getNeighborIndex(cx, cy, 'N', 0);
          nVector = [0.0, 1.0];
        }
      }
      if (!ignoreW && eWest === 0) {
        wNeighborsFound = true;
        neighborsFound = true;
        neighborCount++;
        if (eWestCenter === EDGE_DIAGONAL_ULLR) {
          wNeighborIndex = getNeighborIndex(cx, cy, 'W', 1);
          wVector = [-0.75, 0.25];
        } else if (eWestCenter === EDGE_DIAGONAL_LLUR) {
          wNeighborIndex = getNeighborIndex(cx, cy, 'W', 1);
          wVector = [-0.75, -0.25];
        } else {
          wNeighborIndex = getNeighborIndex(cx, cy, 'W', 0);
          wVector = [-1.0, 0.0];
        }
      }
      if (!ignoreS && eSouth === 0) {
        sNeighborsFound = true;
        neighborsFound = true;
        neighborCount++;
        if (eSouthCenter === EDGE_DIAGONAL_ULLR) {
          sNeighborIndex = getNeighborIndex(cx, cy, 'S', 1);
          sVector = [0.25, -0.75];
        } else if (eSouthCenter === EDGE_DIAGONAL_LLUR) {
          sNeighborIndex = getNeighborIndex(cx, cy, 'S', 0);
          sVector = [-0.25, -0.75];
        } else {
          sNeighborIndex = getNeighborIndex(cx, cy, 'S', 0);
          sVector = [0.0, -1.0];
        }
      }
      if (!ignoreE && eEast === 0) {
        eNeighborsFound = true;
        neighborsFound = true;
        neighborCount++;
        if (eEastCenter === EDGE_DIAGONAL_ULLR) {
          eNeighborIndex = getNeighborIndex(cx, cy, 'E', 0);
          eVector = [0.75, -0.25];
        } else if (eEastCenter === EDGE_DIAGONAL_LLUR) {
          eNeighborIndex = getNeighborIndex(cx, cy, 'E', 0);
          eVector = [0.75, 0.25];
        } else {
          eNeighborIndex = getNeighborIndex(cx, cy, 'E', 0);
          eVector = [1.0, 0.0];
        }
      }

      if (neighborsFound) {
        const LLPixelColorIndex = [cx, cy];
        const ULPixelColorIndex = [cx, cy + 1];
        const LRPixelColorIndex = [cx + 1, cy];
        const URPixelColorIndex = [cx + 1, cy + 1];

        const centerPos = [cx + 0.5, cy + 0.5];

        if (eCenter === EDGE_DIAGONAL_ULLR) {
          let twoNeighbors = true;
          v0_pos = [centerPos[0] - 0.25, centerPos[1] - 0.25];
          let sIndex = sNeighborIndex;
          let wIndex = wNeighborIndex;
          if (sNeighborsFound) {
            v0_flags = HAS_SOUTHERN_NEIGHBOR | HAS_SOUTHERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (wNeighborsFound) {
            v0_flags |= HAS_WESTERN_NEIGHBOR | HAS_WESTERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (twoNeighbors) {
            if (checkForCorner([sVector[0] + 0.25, sVector[1] + 0.25], [wVector[0] + 0.25, wVector[1] + 0.25])) {
              v0_flags |= DONT_OPTIMIZE_S | DONT_OPTIMIZE_W;
            }
          }
          v0_neighbors = [-1, -1, sIndex, wIndex];

          twoNeighbors = true;
          v1_pos = [centerPos[0] + 0.25, centerPos[1] + 0.25];
          let nIndex = nNeighborIndex;
          let eIndex = eNeighborIndex;
          if (nNeighborsFound) {
            v1_flags = HAS_NORTHERN_NEIGHBOR | HAS_NORTHERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (eNeighborsFound) {
            v1_flags |= HAS_EASTERN_NEIGHBOR | HAS_EASTERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (twoNeighbors) {
            if (checkForCorner([nVector[0] - 0.25, nVector[1] - 0.25], [eVector[0] - 0.25, eVector[1] - 0.25])) {
              v1_flags |= DONT_OPTIMIZE_N | DONT_OPTIMIZE_E;
            }
          }
          v1_neighbors = [nIndex, eIndex, -1, -1];
        } else if (eCenter === EDGE_DIAGONAL_LLUR) {
          let twoNeighbors = true;
          v0_pos = [centerPos[0] - 0.25, centerPos[1] + 0.25];
          let nIndex = nNeighborIndex;
          let wIndex = wNeighborIndex;
          if (nNeighborsFound) {
            v0_flags = HAS_NORTHERN_NEIGHBOR | HAS_NORTHERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (wNeighborsFound) {
            v0_flags |= HAS_WESTERN_NEIGHBOR | HAS_WESTERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (twoNeighbors) {
            if (checkForCorner([nVector[0] + 0.25, nVector[1] - 0.25], [wVector[0] + 0.25, wVector[1] - 0.25])) {
              v0_flags |= DONT_OPTIMIZE_N | DONT_OPTIMIZE_W;
            }
          }
          v0_neighbors = [nIndex, -1, -1, wIndex];

          twoNeighbors = true;
          v1_pos = [centerPos[0] + 0.25, centerPos[1] - 0.25];
          let sIndex = sNeighborIndex;
          let eIndex = eNeighborIndex;
          if (sNeighborsFound) {
            v1_flags = HAS_SOUTHERN_NEIGHBOR | HAS_SOUTHERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (eNeighborsFound) {
            v1_flags |= HAS_EASTERN_NEIGHBOR | HAS_EASTERN_SPLINE;
          } else {
            twoNeighbors = false;
          }
          if (twoNeighbors) {
            if (checkForCorner([sVector[0] - 0.25, sVector[1] + 0.25], [eVector[0] - 0.25, eVector[1] + 0.25])) {
              v1_flags |= DONT_OPTIMIZE_S | DONT_OPTIMIZE_E;
            }
          }
          v1_neighbors = [-1, eIndex, sIndex, -1];
        } else {
          v0_pos = [centerPos[0], centerPos[1]];
          let nIndex = nNeighborIndex;
          let eIndex = eNeighborIndex;
          let sIndex = sNeighborIndex;
          let wIndex = wNeighborIndex;
          if (nNeighborsFound) {
            v0_flags |= HAS_NORTHERN_NEIGHBOR;
          }
          if (eNeighborsFound) {
            v0_flags |= HAS_EASTERN_NEIGHBOR;
          }
          if (sNeighborsFound) {
            v0_flags |= HAS_SOUTHERN_NEIGHBOR;
          }
          if (wNeighborsFound) {
            v0_flags |= HAS_WESTERN_NEIGHBOR;
          }

          if (neighborCount === 2) {
            if (nNeighborsFound) {
              v0_flags |= HAS_NORTHERN_SPLINE;
            }
            if (eNeighborsFound) {
              v0_flags |= HAS_EASTERN_SPLINE;
            }
            if (sNeighborsFound) {
              v0_flags |= HAS_SOUTHERN_SPLINE;
            }
            if (wNeighborsFound) {
              v0_flags |= HAS_WESTERN_SPLINE;
            }
          } else if (neighborCount === 3) {
            let contours = 0;
            let contourCount = 0;
            const p = [null, null, null];
            if (nNeighborsFound && isContour(src, ULPixelColorIndex, URPixelColorIndex)) {
              p[contourCount++] = nVector;
              contours |= HAS_NORTHERN_SPLINE;
            }
            if (eNeighborsFound && isContour(src, URPixelColorIndex, LRPixelColorIndex)) {
              p[contourCount++] = eVector;
              contours |= HAS_EASTERN_SPLINE;
            }
            if (sNeighborsFound && isContour(src, LRPixelColorIndex, LLPixelColorIndex)) {
              p[contourCount++] = sVector;
              contours |= HAS_SOUTHERN_SPLINE;
            }
            if (wNeighborsFound && isContour(src, LLPixelColorIndex, ULPixelColorIndex)) {
              p[contourCount++] = wVector;
              contours |= HAS_WESTERN_SPLINE;
            }
            if (contourCount === 2) {
              v0_flags |= contours | HAS_CORRECTED_POSITION;
              v1_pos = calcAdjustedPoint([centerPos[0] + p[0][0], centerPos[1] + p[0][1]], centerPos, [centerPos[0] + p[1][0], centerPos[1] + p[1][1]]);
              v1_flags = -1;
            } else {
              if (nNeighborsFound && sNeighborsFound) {
                v0_flags |= HAS_NORTHERN_SPLINE | HAS_SOUTHERN_SPLINE | HAS_CORRECTED_POSITION;
                v1_pos = calcAdjustedPoint([centerPos[0] + nVector[0], centerPos[1] + nVector[1]], centerPos, [centerPos[0] + sVector[0], centerPos[1] + sVector[1]]);
                v1_flags = -1;
              } else {
                v0_flags |= HAS_EASTERN_SPLINE | HAS_WESTERN_SPLINE | HAS_CORRECTED_POSITION;
                v1_pos = calcAdjustedPoint([centerPos[0] + eVector[0], centerPos[1] + eVector[1]], centerPos, [centerPos[0] + wVector[0], centerPos[1] + wVector[1]]);
                v1_flags = -1;
              }
            }
          }
          v0_neighbors = [nIndex, eIndex, sIndex, wIndex];
        }
      }

      const baseIndex = (cy * (w - 1) + cx) * 2;
      pos[baseIndex * 2] = v0_pos[0];
      pos[baseIndex * 2 + 1] = v0_pos[1];
      neighbors[baseIndex * 4] = v0_neighbors[0];
      neighbors[baseIndex * 4 + 1] = v0_neighbors[1];
      neighbors[baseIndex * 4 + 2] = v0_neighbors[2];
      neighbors[baseIndex * 4 + 3] = v0_neighbors[3];
      flags[baseIndex] = v0_flags;

      pos[(baseIndex + 1) * 2] = v1_pos[0];
      pos[(baseIndex + 1) * 2 + 1] = v1_pos[1];
      neighbors[(baseIndex + 1) * 4] = v1_neighbors[0];
      neighbors[(baseIndex + 1) * 4 + 1] = v1_neighbors[1];
      neighbors[(baseIndex + 1) * 4 + 2] = v1_neighbors[2];
      neighbors[(baseIndex + 1) * 4 + 3] = v1_neighbors[3];
      flags[baseIndex + 1] = v1_flags;
    }
  }

  return { pos, neighbors, flags };
}

function optimizeCellGraph(cell, width, height) {
  const count = cell.flags.length;
  const optimized = new Float32Array(cell.pos.length);
  optimized.set(cell.pos);

  function getPos(idx) {
    return [cell.pos[idx * 2], cell.pos[idx * 2 + 1]];
  }
  function getPosOpt(idx) {
    return [optimized[idx * 2], optimized[idx * 2 + 1]];
  }

  function calcPositionalEnergy(pNew, pOld) {
    const dx = pNew[0] - pOld[0];
    const dy = pNew[1] - pOld[1];
    const distSq = POSITIONAL_ENERGY_SCALING * POSITIONAL_ENERGY_SCALING * (dx * dx + dy * dy);
    return distSq * distSq;
  }

  function calcSegmentCurveEnergy(node1, node2, node3) {
    const tx = node1[0] - 2 * node2[0] + node3[0];
    const ty = node1[1] - 2 * node2[1] + node3[1];
    return tx * tx + ty * ty;
  }

  function calcGradient(node1, node2, node3) {
    return [8 * node2[0] - 4 * node1[0] - 4 * node3[0], 8 * node2[1] - 4 * node1[1] - 4 * node3[1]];
  }

  function findBracket(pos, splineNeighbors, gradient) {
    let ax = BRACKET_SEARCH_A;
    let bx = BRACKET_SEARCH_B;
    let pOpt = [pos[0] - gradient[0] * ax, pos[1] - gradient[1] * ax];
    let fa = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
    pOpt = [pos[0] - gradient[0] * bx, pos[1] - gradient[1] * bx];
    let fb = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
    if (fb > fa) {
      let dum = ax; ax = bx; bx = dum;
      dum = fb; fb = fa; fa = dum;
    }
    let cx = bx + GOLD * (bx - ax);
    pOpt = [pos[0] - gradient[0] * cx, pos[1] - gradient[1] * cx];
    let fc = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
    while (fb > fc) {
      const r = (bx - ax) * (fb - fc);
      const q = (bx - cx) * (fb - fa);
      const qr = q - r;
      let u = bx - ((bx - cx) * q - (bx - ax) * r) / (2.0 * sign(qr) * max(abs(qr), TINY));
      const ulim = bx + GLIMIT * (cx - bx);
      let fu;
      if ((bx - u) * (u - cx) > 0.0) {
        pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
        fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
        if (fu < fc) {
          return [bx, u, cx];
        }
        if (fu > fb) {
          return [ax, bx, u];
        }
        u = cx + GOLD * (cx - bx);
        pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
        fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
      } else if ((cx - u) * (u - ulim) > 0.0) {
        pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
        fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
        if (fu < fc) {
          let dum = cx + GOLD * (cx - bx);
          bx = cx; cx = u; u = dum;
          fb = fc; fc = fu;
          pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
          fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
        }
      } else if ((u - ulim) * (ulim - cx) >= 0.0) {
        u = ulim;
        pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
        fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
      } else {
        u = cx + GOLD * (cx - bx);
        pOpt = [pos[0] - gradient[0] * u, pos[1] - gradient[1] * u];
        fu = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
      }
      ax = bx; bx = cx; cx = u;
      fa = fb; fb = fc; fc = fu;
    }
    return [ax, bx, cx];
  }

  function searchOffset(pos, splineNeighbors) {
    let gradient = calcGradient(splineNeighbors[0], pos, splineNeighbors[1]);
    const glen = hypot(gradient[0], gradient[1]);
    if (glen <= 0.0) {
      return [0, 0, 0];
    }
    gradient = [gradient[0] / glen, gradient[1] / glen];
    const bracket = findBracket(pos, splineNeighbors, gradient);
    let x0 = bracket[0];
    let x1 = 0;
    let x2 = 0;
    let x3 = bracket[2];
    if (abs(bracket[2] - bracket[1]) > abs(bracket[1] - bracket[0])) {
      x1 = bracket[1];
      x2 = bracket[1] + C * (bracket[2] - bracket[1]);
    } else {
      x1 = bracket[1] - C * (bracket[1] - bracket[0]);
      x2 = bracket[1];
    }
    let pOpt = [pos[0] - gradient[0] * x1, pos[1] - gradient[1] * x1];
    let f1 = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
    pOpt = [pos[0] - gradient[0] * x2, pos[1] - gradient[1] * x2];
    let f2 = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
    let counter = 0;
    let fx;
    while (abs(x3 - x0) > TOL * (abs(x1) + abs(x2)) && (counter < LIMIT_SEARCH_ITERATIONS)) {
      counter++;
      if (f2 < f1) {
        x0 = x1; x1 = x2; x2 = R * x1 + C * x3;
        pOpt = [pos[0] - gradient[0] * x2, pos[1] - gradient[1] * x2];
        fx = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
        f1 = f2; f2 = fx;
      } else {
        x3 = x2; x2 = x1; x1 = R * x2 + C * x0;
        pOpt = [pos[0] - gradient[0] * x1, pos[1] - gradient[1] * x1];
        fx = calcSegmentCurveEnergy(splineNeighbors[0], pOpt, splineNeighbors[1]) + calcPositionalEnergy(pOpt, pos);
        f2 = f1; f1 = fx;
      }
    }
    const offset = (f1 < f2) ? x1 : x2;
    return [gradient[0], gradient[1], offset];
  }

  for (let i = 0; i < count; i++) {
    const flags = cell.flags[i];
    if (flags & (HAS_NORTHERN_SPLINE|HAS_EASTERN_SPLINE|HAS_SOUTHERN_SPLINE|HAS_WESTERN_SPLINE)) {
      const base = i * 4;
      const neighbors = [cell.neighbors[base], cell.neighbors[base + 1], cell.neighbors[base + 2], cell.neighbors[base + 3]];
      const pos = getPosOpt(i);

      let splineNeighbors = [null, null];
      let splineCount = 0;
      let splineNoOpt = false;

      const hasN = Boolean(flags & HAS_NORTHERN_SPLINE);
      const hasE = Boolean(flags & HAS_EASTERN_SPLINE);
      const hasS = Boolean(flags & HAS_SOUTHERN_SPLINE);
      const hasW = Boolean(flags & HAS_WESTERN_SPLINE);

      if (hasN) {
        const neighborflags = cell.flags[neighbors[0]] | 0;
        if ((flags & DONT_OPTIMIZE_N) || (neighborflags & DONT_OPTIMIZE_S)) {
          splineNoOpt = true;
        }
        if (!splineNoOpt) {
          if ((neighborflags & HAS_CORRECTED_POSITION) && !(neighborflags & HAS_SOUTHERN_SPLINE)) {
            splineNeighbors[splineCount++] = getPos(neighbors[0] + 1);
          } else {
            splineNeighbors[splineCount++] = getPos(neighbors[0]);
          }
        }
      }
      if (hasE) {
        const neighborflags = cell.flags[neighbors[1]] | 0;
        if ((flags & DONT_OPTIMIZE_E) || (neighborflags & DONT_OPTIMIZE_W)) {
          splineNoOpt = true;
        }
        if (!splineNoOpt) {
          if ((neighborflags & HAS_CORRECTED_POSITION) && !(neighborflags & HAS_WESTERN_SPLINE)) {
            splineNeighbors[splineCount++] = getPos(neighbors[1] + 1);
          } else {
            splineNeighbors[splineCount++] = getPos(neighbors[1]);
          }
        }
      }
      if (hasS) {
        const neighborflags = cell.flags[neighbors[2]] | 0;
        if ((flags & DONT_OPTIMIZE_S) || (neighborflags & DONT_OPTIMIZE_N)) {
          splineNoOpt = true;
        }
        if (!splineNoOpt) {
          if ((neighborflags & HAS_CORRECTED_POSITION) && !(neighborflags & HAS_NORTHERN_SPLINE)) {
            splineNeighbors[splineCount++] = getPos(neighbors[2] + 1);
          } else {
            splineNeighbors[splineCount++] = getPos(neighbors[2]);
          }
        }
      }
      if (hasW) {
        const neighborflags = cell.flags[neighbors[3]] | 0;
        if ((flags & DONT_OPTIMIZE_W) || (neighborflags & DONT_OPTIMIZE_E)) {
          splineNoOpt = true;
        }
        if (!splineNoOpt) {
          if ((neighborflags & HAS_CORRECTED_POSITION) && !(neighborflags & HAS_EASTERN_SPLINE)) {
            splineNeighbors[splineCount++] = getPos(neighbors[3] + 1);
          } else {
            splineNeighbors[splineCount++] = getPos(neighbors[3]);
          }
        }
      }

      if (splineCount === 2 && !splineNoOpt) {
        const shift = searchOffset(pos, splineNeighbors);
        optimized[i * 2] = pos[0] - shift[0] * shift[2];
        optimized[i * 2 + 1] = pos[1] - shift[1] * shift[2];
      }
    }
  }

  return optimized;
}

function computeCorrectedPositions(cell, optimized) {
  const count = cell.flags.length;
  const corrected = new Float32Array(optimized.length);
  corrected.set(optimized);

  function getPos(idx) {
    return [optimized[idx * 2], optimized[idx * 2 + 1]];
  }

  function calcAdjustedPoint(p0, p1, p2) {
    return [0.125 * p0[0] + 0.75 * p1[0] + 0.125 * p2[0], 0.125 * p0[1] + 0.75 * p1[1] + 0.125 * p2[1]];
  }

  for (let i = 0; i < count; i++) {
    const flags = cell.flags[i];
    if (flags === -1) {
      const parentId = i - 1;
      const parentPosition = getPos(parentId);
      const parentFlags = cell.flags[parentId] | 0;
      const base = parentId * 4;
      const parentNeighborIndices = [cell.neighbors[base], cell.neighbors[base + 1], cell.neighbors[base + 2], cell.neighbors[base + 3]];
      const splinePoints = [null, null];
      let countSp = 0;
      if (parentFlags & HAS_NORTHERN_SPLINE) {
        splinePoints[countSp++] = getPos(parentNeighborIndices[0]);
      }
      if (parentFlags & HAS_EASTERN_SPLINE) {
        splinePoints[countSp++] = getPos(parentNeighborIndices[1]);
      }
      if (parentFlags & HAS_SOUTHERN_SPLINE) {
        splinePoints[countSp++] = getPos(parentNeighborIndices[2]);
      }
      if (parentFlags & HAS_WESTERN_SPLINE) {
        splinePoints[countSp++] = getPos(parentNeighborIndices[3]);
      }
      if (countSp === 2) {
        const p = calcAdjustedPoint(splinePoints[0], parentPosition, splinePoints[1]);
        corrected[i * 2] = p[0];
        corrected[i * 2 + 1] = p[1];
      } else {
        corrected[i * 2] = parentPosition[0];
        corrected[i * 2 + 1] = parentPosition[1];
      }
    }
  }

  return corrected;
}

function gaussRasterize(src, sim, cell, positions, outW, outH, needSplines, outputSimilarityMask, similarity) {
  const w = src.width;
  const h = src.height;
  const out = new Uint8Array(outW * outH * 4);

  function getG(x, y) {
    if (x < 0 || y < 0 || x >= sim.w || y >= sim.h) {
      return 0;
    }
    return sim.g[y * sim.w + x] | 0;
  }

  function getPos(idx) {
    return [positions[idx * 2], positions[idx * 2 + 1]];
  }

  function getNeighborIndex(sourceIndex, dir) {
    const base = sourceIndex * 4;
    if (dir === NORTH) {
      return cell.neighbors[base];
    }
    if (dir === EAST) {
      return cell.neighbors[base + 1];
    }
    if (dir === SOUTH) {
      return cell.neighbors[base + 2];
    }
    if (dir === WEST) {
      return cell.neighbors[base + 3];
    }
    return -1;
  }

  function calcSplinePoint(p0, p1, p2, t) {
    const t2 = 0.5 * t * t;
    const a = t2 - t + 0.5;
    const b = -2.0 * t2 + t + 0.5;
    return [a * p0[0] + b * p1[0] + t2 * p2[0], a * p0[1] + b * p1[1] + t2 * p2[1]];
  }

  function intersects(a0, a1, b0, b1) {
    const r = [a1[0] - a0[0], a1[1] - a0[1]];
    const s = [b1[0] - b0[0], b1[1] - b0[1]];
    const rXs = r[0] * s[1] - r[1] * s[0];
    if (rXs === 0.0) {
      return false;
    }
    const ba = [b0[0] - a0[0], b0[1] - a0[1]];
    const t = (ba[0] * s[1] - ba[1] * s[0]) / rXs;
    if (t < 0.0 || t > 1.0) {
      return false;
    }
    const u = (ba[0] * r[1] - ba[1] * r[0]) / rXs;
    if (u < 0.0 || u > 1.0) {
      return false;
    }
    return true;
  }

  function computeValence(flags) {
    let v = 0;
    if (flags & HAS_NORTHERN_NEIGHBOR) {
      v++;
    }
    if (flags & HAS_EASTERN_NEIGHBOR) {
      v++;
    }
    if (flags & HAS_SOUTHERN_NEIGHBOR) {
      v++;
    }
    if (flags & HAS_WESTERN_NEIGHBOR) {
      v++;
    }
    return v;
  }

  function getCPs(node0neighborIndex, dir) {
    let cpArray = [node0neighborIndex, -1];
    let checkFwd = [0, 0, 0];
    let chkdirs = [0, 0];
    let checkBack = 0;
    if (dir === NORTH) {
      checkFwd = [HAS_NORTHERN_SPLINE, HAS_EASTERN_SPLINE, HAS_WESTERN_SPLINE];
      checkBack = HAS_SOUTHERN_SPLINE;
      chkdirs = [EAST, WEST];
    } else if (dir === EAST) {
      checkFwd = [HAS_EASTERN_SPLINE, HAS_SOUTHERN_SPLINE, HAS_NORTHERN_SPLINE];
      checkBack = HAS_WESTERN_SPLINE;
      chkdirs = [SOUTH, NORTH];
    } else if (dir === SOUTH) {
      checkFwd = [HAS_SOUTHERN_SPLINE, HAS_WESTERN_SPLINE, HAS_EASTERN_SPLINE];
      checkBack = HAS_NORTHERN_SPLINE;
      chkdirs = [WEST, EAST];
    } else if (dir === WEST) {
      checkFwd = [HAS_WESTERN_SPLINE, HAS_NORTHERN_SPLINE, HAS_SOUTHERN_SPLINE];
      checkBack = HAS_EASTERN_SPLINE;
      chkdirs = [NORTH, SOUTH];
    }
    const node0neighborFlags = cell.flags[node0neighborIndex] | 0;
    if ((node0neighborFlags & checkBack) === checkBack) {
      if ((node0neighborFlags & checkFwd[0]) === checkFwd[0]) {
        const neighborsNeighborIndex = getNeighborIndex(node0neighborIndex, dir);
        const neighborsNeighborflags = cell.flags[neighborsNeighborIndex] | 0;
        if (neighborsNeighborflags & HAS_CORRECTED_POSITION) {
          cpArray[1] = neighborsNeighborIndex + 1;
        } else {
          cpArray[1] = neighborsNeighborIndex;
        }
      } else if ((node0neighborFlags & checkFwd[1]) === checkFwd[1]) {
        const neighborsNeighborIndex = getNeighborIndex(node0neighborIndex, chkdirs[0]);
        const neighborsNeighborflags = cell.flags[neighborsNeighborIndex] | 0;
        if (neighborsNeighborflags & HAS_CORRECTED_POSITION) {
          cpArray[1] = neighborsNeighborIndex + 1;
        } else {
          cpArray[1] = neighborsNeighborIndex;
        }
      } else if ((node0neighborFlags & checkFwd[2]) === checkFwd[2]) {
        const neighborsNeighborIndex = getNeighborIndex(node0neighborIndex, chkdirs[1]);
        const neighborsNeighborflags = cell.flags[neighborsNeighborIndex] | 0;
        if (neighborsNeighborflags & HAS_CORRECTED_POSITION) {
          cpArray[1] = neighborsNeighborIndex + 1;
        } else {
          cpArray[1] = neighborsNeighborIndex;
        }
      }
    } else {
      if (node0neighborFlags & HAS_CORRECTED_POSITION) {
        cpArray[0]++;
      }
    }
    return cpArray;
  }

  const allSplines = needSplines ? [] : null;
  const allSplinesDone = {};
  let similarityData;
  let simImage;
  if (outputSimilarityMask) {
    similarityData = new Uint8Array(outW * outH * 4);
    simImage = {
      ...src,
      data: similarity,
    };
  }

  for (let oy = 0; oy < outH; oy++) {
    for (let ox = 0; ox < outW; ox++) {
      let influencingPixels = [true, true, true, true];
      const cellSpaceCoords = [
        (w * (ox + 0.5) / outW) - 0.5 + 0.00001,
        (h * (oy + 0.5) / outH) - 0.5 + 0.00001,
      ];
      const fragmentBaseKnotIndex = (2 * floor(cellSpaceCoords[0]) + floor(cellSpaceCoords[1]) * 2 * (w - 1)) | 0;
      const node0flags = cell.flags[fragmentBaseKnotIndex] | 0;
      let hasCorrectedPosition = false;

      const ULCoords = [floor(cellSpaceCoords[0]), ceil(cellSpaceCoords[1])];
      const URCoords = [ceil(cellSpaceCoords[0]), ceil(cellSpaceCoords[1])];
      const LLCoords = [floor(cellSpaceCoords[0]), floor(cellSpaceCoords[1])];
      const LRCoords = [ceil(cellSpaceCoords[0]), floor(cellSpaceCoords[1])];

      function findSegmentIntersections(p0, p1, p2) {
        if (allSplines) {
          const key = [p0.join(), p1.join(), p2.join()].join();
          if (!allSplinesDone[key]) {
            allSplinesDone[key] = true;
            allSplines.push([p0, p1, p2]);
          }
        }
        let pointA = calcSplinePoint(p0, p1, p2, 0.0);
        for (let t = STEP; t < (1.0 + STEP); t += STEP) {
          const pointB = calcSplinePoint(p0, p1, p2, t);
          if (influencingPixels[0] && intersects(cellSpaceCoords, ULCoords, pointA, pointB)) {
            influencingPixels[0] = false;
          }
          if (influencingPixels[1] && intersects(cellSpaceCoords, URCoords, pointA, pointB)) {
            influencingPixels[1] = false;
          }
          if (influencingPixels[2] && intersects(cellSpaceCoords, LLCoords, pointA, pointB)) {
            influencingPixels[2] = false;
          }
          if (influencingPixels[3] && intersects(cellSpaceCoords, LRCoords, pointA, pointB)) {
            influencingPixels[3] = false;
          }
          pointA = pointB;
        }
      }

      if (node0flags > 0) {
        const node0neighbors = [
          cell.neighbors[fragmentBaseKnotIndex * 4],
          cell.neighbors[fragmentBaseKnotIndex * 4 + 1],
          cell.neighbors[fragmentBaseKnotIndex * 4 + 2],
          cell.neighbors[fragmentBaseKnotIndex * 4 + 3],
        ];
        const node0valence = computeValence(node0flags);
        let node0pos = getPos(fragmentBaseKnotIndex);
        if (node0valence === 1) {
          let cpArray = [-1, -1];
          if (node0flags & HAS_NORTHERN_NEIGHBOR) {
            cpArray = getCPs(node0neighbors[0], NORTH);
          } else if (node0flags & HAS_EASTERN_NEIGHBOR) {
            cpArray = getCPs(node0neighbors[1], EAST);
          } else if (node0flags & HAS_SOUTHERN_NEIGHBOR) {
            cpArray = getCPs(node0neighbors[2], SOUTH);
          } else if (node0flags & HAS_WESTERN_NEIGHBOR) {
            cpArray = getCPs(node0neighbors[3], WEST);
          }
          const p1pos = getPos(cpArray[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            const p2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
        } else if (node0valence === 2) {
          let cpArray = [-1, -1, -1, -1];
          let foundFirst = false;
          if (node0flags & HAS_NORTHERN_NEIGHBOR) { cpArray[0] = getCPs(node0neighbors[0], NORTH)[0]; cpArray[1] = getCPs(node0neighbors[0], NORTH)[1]; foundFirst = true; }
          if (node0flags & HAS_EASTERN_NEIGHBOR) {
            const tmp = getCPs(node0neighbors[1], EAST);
            if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; }
            else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
          }
          if (node0flags & HAS_SOUTHERN_NEIGHBOR) {
            const tmp = getCPs(node0neighbors[2], SOUTH);
            if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; }
            else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
          }
          if (node0flags & HAS_WESTERN_NEIGHBOR) {
            const tmp = getCPs(node0neighbors[3], WEST);
            cpArray[2] = tmp[0]; cpArray[3] = tmp[1];
          }
          const pm1pos = getPos(cpArray[0]);
          const p1pos = getPos(cpArray[2]);
          findSegmentIntersections(pm1pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            const pm2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, pm1pos, pm2pos);
          } else {
            findSegmentIntersections(node0pos, pm1pos, pm1pos);
          }
          if (cpArray[3] > -1) {
            const p2pos = getPos(cpArray[3]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
        } else if (node0valence === 3) {
          hasCorrectedPosition = true;
          let cpArray = [-1, -1, -1, -1];
          let foundFirst = false;
          let tBaseDir = 0;
          let tBaseNeighborIndex = -1;
          if (node0flags & HAS_NORTHERN_NEIGHBOR) {
            if (node0flags & HAS_NORTHERN_SPLINE) { const tmp = getCPs(node0neighbors[0], NORTH); cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            else { tBaseDir = NORTH; tBaseNeighborIndex = node0neighbors[0]; }
          }
          if (node0flags & HAS_EASTERN_NEIGHBOR) {
            if (node0flags & HAS_EASTERN_SPLINE) {
              const tmp = getCPs(node0neighbors[1], EAST);
              if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; } else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            } else { tBaseDir = EAST; tBaseNeighborIndex = node0neighbors[1]; }
          }
          if (node0flags & HAS_SOUTHERN_NEIGHBOR) {
            if (node0flags & HAS_SOUTHERN_SPLINE) {
              const tmp = getCPs(node0neighbors[2], SOUTH);
              if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; } else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            } else { tBaseDir = SOUTH; tBaseNeighborIndex = node0neighbors[2]; }
          }
          if (node0flags & HAS_WESTERN_NEIGHBOR) {
            if (node0flags & HAS_WESTERN_SPLINE) {
              const tmp = getCPs(node0neighbors[3], WEST);
              cpArray[2] = tmp[0]; cpArray[3] = tmp[1];
            } else { tBaseDir = WEST; tBaseNeighborIndex = node0neighbors[3]; }
          }
          const pm1pos = getPos(cpArray[0]);
          const p1pos = getPos(cpArray[2]);
          findSegmentIntersections(pm1pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            const pm2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, pm1pos, pm2pos);
          } else {
            findSegmentIntersections(node0pos, pm1pos, pm1pos);
          }
          if (cpArray[3] > -1) {
            const p2pos = getPos(cpArray[3]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
          const tCP = getCPs(tBaseNeighborIndex, tBaseDir);
          node0pos = getPos(fragmentBaseKnotIndex + 1);
          const p1pos2 = getPos(tCP[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos2);
          if (tCP[1] > -1) {
            const p2pos2 = getPos(tCP[1]);
            findSegmentIntersections(node0pos, p1pos2, p2pos2);
          } else {
            findSegmentIntersections(node0pos, p1pos2, p1pos2);
          }
        } else {
          let cpArray = getCPs(node0neighbors[0], NORTH);
          let p1pos = getPos(cpArray[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            let p2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
          cpArray = getCPs(node0neighbors[1], EAST);
          p1pos = getPos(cpArray[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            let p2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
          cpArray = getCPs(node0neighbors[2], SOUTH);
          p1pos = getPos(cpArray[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            let p2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
          cpArray = getCPs(node0neighbors[3], WEST);
          p1pos = getPos(cpArray[0]);
          findSegmentIntersections(node0pos, node0pos, p1pos);
          if (cpArray[1] > -1) {
            let p2pos = getPos(cpArray[1]);
            findSegmentIntersections(node0pos, p1pos, p2pos);
          } else {
            findSegmentIntersections(node0pos, p1pos, p1pos);
          }
        }
      }

      if (!hasCorrectedPosition) {
        const node1flags = cell.flags[fragmentBaseKnotIndex + 1] | 0;
        if (node1flags > 0) {
          const node1neighbors = [
            cell.neighbors[(fragmentBaseKnotIndex + 1) * 4],
            cell.neighbors[(fragmentBaseKnotIndex + 1) * 4 + 1],
            cell.neighbors[(fragmentBaseKnotIndex + 1) * 4 + 2],
            cell.neighbors[(fragmentBaseKnotIndex + 1) * 4 + 3],
          ];
          const node1valence = computeValence(node1flags);
          const node1pos = getPos(fragmentBaseKnotIndex + 1);
          if (node1valence === 1) {
            let cpArray = [-1, -1];
            if (node1flags & HAS_NORTHERN_NEIGHBOR) {
              cpArray = getCPs(node1neighbors[0], NORTH);
            } else if (node1flags & HAS_EASTERN_NEIGHBOR) {
              cpArray = getCPs(node1neighbors[1], EAST);
            } else if (node1flags & HAS_SOUTHERN_NEIGHBOR) {
              cpArray = getCPs(node1neighbors[2], SOUTH);
            } else if (node1flags & HAS_WESTERN_NEIGHBOR) {
              cpArray = getCPs(node1neighbors[3], WEST);
            }
            const p1pos = getPos(cpArray[0]);
            findSegmentIntersections(node1pos, node1pos, p1pos);
            if (cpArray[1] > -1) {
              const p2pos = getPos(cpArray[1]);
              findSegmentIntersections(node1pos, p1pos, p2pos);
            } else {
              findSegmentIntersections(node1pos, p1pos, p1pos);
            }
          } else if (node1valence === 2) {
            let cpArray = [-1, -1, -1, -1];
            let foundFirst = false;
            if (node1flags & HAS_NORTHERN_NEIGHBOR) { const tmp = getCPs(node1neighbors[0], NORTH); cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            if (node1flags & HAS_EASTERN_NEIGHBOR) {
              const tmp = getCPs(node1neighbors[1], EAST);
              if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; } else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            }
            if (node1flags & HAS_SOUTHERN_NEIGHBOR) {
              const tmp = getCPs(node1neighbors[2], SOUTH);
              if (foundFirst) { cpArray[2] = tmp[0]; cpArray[3] = tmp[1]; } else { cpArray[0] = tmp[0]; cpArray[1] = tmp[1]; foundFirst = true; }
            }
            if (node1flags & HAS_WESTERN_NEIGHBOR) {
              const tmp = getCPs(node1neighbors[3], WEST);
              cpArray[2] = tmp[0]; cpArray[3] = tmp[1];
            }
            const pm1pos = getPos(cpArray[0]);
            const p1pos = getPos(cpArray[2]);
            findSegmentIntersections(pm1pos, node1pos, p1pos);
            if (cpArray[1] > -1) {
              const pm2pos = getPos(cpArray[1]);
              findSegmentIntersections(node1pos, pm1pos, pm2pos);
            } else {
              findSegmentIntersections(node1pos, pm1pos, pm1pos);
            }
            if (cpArray[3] > -1) {
              const p2pos = getPos(cpArray[3]);
              findSegmentIntersections(node1pos, p1pos, p2pos);
            } else {
              findSegmentIntersections(node1pos, p1pos, p1pos);
            }
          }
        }
      }

      let colorSum = [0, 0, 0, 0];
      let weightSum = 0.0;
      let maxWeight = 0;
      let maxSimilarity = null;

      function addWeightedColor(px, py) {
        const col = fetchPixelRGBA8(src, px, py);
        const dx = cellSpaceCoords[0] - px;
        const dy = cellSpaceCoords[1] - py;
        const distSq = dx * dx + dy * dy;
        const weight = exp(-distSq * GAUSS_MULTIPLIER);
        colorSum[0] += col[0] * weight;
        colorSum[1] += col[1] * weight;
        colorSum[2] += col[2] * weight;
        colorSum[3] += col[3] * weight;
        weightSum += weight;
        if (outputSimilarityMask && weight >= maxWeight) {
          // note: would also be reasonable to blend this like we blend the colors
          maxWeight = weight;
          maxSimilarity = fetchPixelRGBA8(simImage, px, py);
        }
      }

      if (influencingPixels[0]) {
        addWeightedColor(ULCoords[0], ULCoords[1]);
        const edges = getG(2 * ULCoords[0] + 1, 2 * ULCoords[1] + 1);
        if (edges & SOUTHWEST) {
          addWeightedColor(ULCoords[0] - 1, ULCoords[1] - 1);
        }
        if (edges & WEST) {
          addWeightedColor(ULCoords[0] - 1, ULCoords[1]);
        }
        if (edges & NORTHWEST) {
          addWeightedColor(ULCoords[0] - 1, ULCoords[1] + 1);
        }
        if (edges & NORTH) {
          addWeightedColor(ULCoords[0], ULCoords[1] + 1);
        }
        if (edges & NORTHEAST) {
          addWeightedColor(ULCoords[0] + 1, ULCoords[1] + 1);
        }
      }
      if (influencingPixels[1]) {
        addWeightedColor(URCoords[0], URCoords[1]);
        const edges = getG(2 * URCoords[0] + 1, 2 * URCoords[1] + 1);
        if (edges & NORTH) {
          addWeightedColor(URCoords[0], URCoords[1] + 1);
        }
        if (edges & NORTHEAST) {
          addWeightedColor(URCoords[0] + 1, URCoords[1] + 1);
        }
        if (edges & EAST) {
          addWeightedColor(URCoords[0] + 1, URCoords[1]);
        }
        if (edges & SOUTHEAST) {
          addWeightedColor(URCoords[0] + 1, URCoords[1] - 1);
        }
      }
      if (influencingPixels[2]) {
        addWeightedColor(LLCoords[0], LLCoords[1]);
        const edges = getG(2 * LLCoords[0] + 1, 2 * LLCoords[1] + 1);
        if (edges & WEST) {
          addWeightedColor(LLCoords[0] - 1, LLCoords[1]);
        }
        if (edges & SOUTHWEST) {
          addWeightedColor(LLCoords[0] - 1, LLCoords[1] - 1);
        }
        if (edges & SOUTH) {
          addWeightedColor(LLCoords[0], LLCoords[1] - 1);
        }
        if (edges & SOUTHEAST) {
          addWeightedColor(LLCoords[0] + 1, LLCoords[1] - 1);
        }
      }
      if (influencingPixels[3]) {
        addWeightedColor(LRCoords[0], LRCoords[1]);
        const edges = getG(2 * LRCoords[0] + 1, 2 * LRCoords[1] + 1);
        if (edges & NORTHEAST) {
          addWeightedColor(LRCoords[0] + 1, LRCoords[1] + 1);
        }
        if (edges & EAST) {
          addWeightedColor(LRCoords[0] + 1, LRCoords[1]);
        }
        if (edges & SOUTHWEST) {
          addWeightedColor(LRCoords[0] - 1, LRCoords[1] - 1);
        }
        if (edges & SOUTH) {
          addWeightedColor(LRCoords[0], LRCoords[1] - 1);
        }
        if (edges & SOUTHEAST) {
          addWeightedColor(LRCoords[0] + 1, LRCoords[1] - 1);
        }
      }

      const outIdx = (oy * outW + ox) * 4;
      if (weightSum === 0) {
        const nx = round(cellSpaceCoords[0]);
        const ny = round(cellSpaceCoords[1]);
        const col = fetchPixelRGBA8(src, nx, ny);
        out[outIdx] = col[0];
        out[outIdx + 1] = col[1];
        out[outIdx + 2] = col[2];
        out[outIdx + 3] = col[3];
        if (outputSimilarityMask) {
          maxSimilarity = fetchPixelRGBA8(simImage, nx, ny);
        }
      } else {
        out[outIdx] = clampInt(round((colorSum[0] / weightSum)), 0, 255);
        out[outIdx + 1] = clampInt(round((colorSum[1] / weightSum)), 0, 255);
        out[outIdx + 2] = clampInt(round((colorSum[2] / weightSum)), 0, 255);
        out[outIdx + 3] = clampInt(round((colorSum[3] / weightSum)), 0, 255);
      }
      if (outputSimilarityMask) {
        similarityData[outIdx] = maxSimilarity[0];
        similarityData[outIdx + 1] = maxSimilarity[1];
        similarityData[outIdx + 2] = maxSimilarity[2];
        similarityData[outIdx + 3] = maxSimilarity[3];
      }
    }
  }

  return {
    data: out,
    width: outW,
    height: outH,
    allSplines,
    similarityData,
  };
}

function renderSplines(out, outW, outH, inW, inH, allSplines) {
  for (let ii = 0; ii < out.length; ++ii) {
    out[ii] = 0;
  }

  function mapToOutput(p) {
    const x = (p[0] / (inW - 1)) * (outW - 1);
    const y = (p[1] / (inH - 1)) * (outH - 1);
    return [x, y];
  }

  function drawLine(p0, p1) {
    let x0 = round(p0[0]);
    let y0 = round(p0[1]);
    let x1 = round(p1[0]);
    let y1 = round(p1[1]);
    const dx = abs(x1 - x0);
    const dy = abs(y1 - y0);
    const sx = x0 < x1 ? 1 : -1;
    const sy = y0 < y1 ? 1 : -1;
    let err = dx - dy;
    while (true) {
      if (x0 >= 0 && x0 < outW && y0 >= 0 && y0 < outH) {
        const idx = (y0 * outW + x0) * 4;
        out[idx] = 0;
        out[idx + 1] = 0;
        out[idx + 2] = 0;
        out[idx + 3] = 255;
      }
      if (x0 === x1 && y0 === y1) {
        break;
      }
      const e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x0 += sx; }
      if (e2 < dx) { err += dx; y0 += sy; }
    }
  }

  function calcSplinePoint(p0, p1, p2, t) {
    const t2 = 0.5 * t * t;
    const a = t2 - t + 0.5;
    const b = -2.0 * t2 + t + 0.5;
    return [a * p0[0] + b * p1[0] + t2 * p2[0], a * p0[1] + b * p1[1] + t2 * p2[1]];
  }

  for (let i = 0; i < allSplines.length; i++) {
    const spline = allSplines[i];
    const p0 = spline[0];
    const p1 = spline[1];
    const p2 = spline[2];
    let prev = null;
    for (let t = 0.0; t < (1.0 + STEP); t += STEP) {
      const p = calcSplinePoint(p0, p1, p2, t);
      const outP = mapToOutput(p);
      if (prev) {
        drawLine(prev, outP);
      }
      prev = outP;
    }
  }
}

function runPipeline(src, outH, threshold, similarity, renderMode, doOpt, outputSimilarityMask) {
  const inW = src.width | 0;
  const inH = src.height | 0;
  const outHeight = outH | 0;
  const outWidth = max(1, round((inW / inH) * outHeight));

  const similarityThreshold = similarity ? threshold : ((typeof threshold === "number") ? threshold : 255) / 255;

  const sim0 = buildSimilarityGraph(src, similarityThreshold, similarity);
  const sim1 = valenceUpdate(sim0);
  const sim2 = eliminateCrossings(sim1);
  const sim3 = valenceUpdate(sim2);

  const cell = computeCellGraph(src, sim3);
  let corrected;
  if (doOpt) {
    const optimized = optimizeCellGraph(cell, inW, inH);
    corrected = computeCorrectedPositions(cell, optimized);
  } else {
    corrected = computeCorrectedPositions(cell, cell.pos);
  }

  const out = gaussRasterize(
    src,
    sim3, cell, corrected, outWidth, outHeight,
    renderMode === 'splines',
    outputSimilarityMask, similarity);
  if (renderMode === 'splines') {
    renderSplines(out.data, outWidth, outHeight, inW, inH, out.allSplines);
  }

  return out;
}

function scaleImage(src, opts) {
  if (!src || !src.data || typeof src.width !== 'number' || typeof src.height !== 'number') {
    throw new Error('Invalid src image');
  }
  if (!opts || typeof opts.height !== 'number') {
    throw new Error('opts.height is required');
  }
  const inW = src.width | 0;
  const inH = src.height | 0;
  const outH = opts.height | 0;
  const similarity = opts.similarity;
  const threshold = typeof opts.threshold === 'number' ? opts.threshold : (similarity ? 3 : 255);
  const renderMode = opts.renderMode || 'default';
  const outputSimilarityMask = opts.outputSimilarityMask || false;
  const doOpt = opts.doOpt ?? true;
  if (outputSimilarityMask && !similarity) {
    throw new Error('outputSimilarityMask requires a similarity mask input');
  }

  const borderPx = max(0, round(opts.borderPx || 0));
  if (borderPx > 0) {
    const padW = inW + 2 * borderPx;
    const padH = inH + 2 * borderPx;
    const padData = new Uint8Array(padW * padH * 4);
    const padSimilarity = similarity && new Uint8Array(padW * padH * 4);
    // copy src into center, expand into borders
    for (let y = 0; y < padH; y++) {
      const srcRow = min(inH - 1, max(0, y - borderPx)) * inW * 4;
      const dstRow = y * padW * 4 + borderPx * 4;
      padData.set(src.data.subarray(srcRow, srcRow + inW * 4), dstRow);
      if (padSimilarity) {
        padSimilarity.set(similarity.subarray(srcRow, srcRow + inW * 4), dstRow);
      }
      for (let ii = 0; ii < borderPx * 4; ++ii) {
        padData[dstRow - borderPx * 4 + ii] = src.data[srcRow + ii % 4];
        padData[dstRow + inW * 4 + ii] = src.data[srcRow + (inW - 1) * 4 + ii % 4];
        if (padSimilarity) {
          padSimilarity[dstRow - borderPx * 4 + ii] = similarity[srcRow + ii % 4];
          padSimilarity[dstRow + inW * 4 + ii] = similarity[srcRow + (inW - 1) * 4 + ii % 4];
        }
      }
    }
    const scale = outH / inH;
    const outHpad = max(1, round(padH * scale));
    const padded = runPipeline({ data: padData, width: padW, height: padH }, outHpad, threshold, padSimilarity, renderMode, doOpt, outputSimilarityMask);

    const padOut = max(0, round(borderPx * scale));
    const outW = max(1, round((inW / inH) * outH));
    const cropped = new Uint8Array(outW * outH * 4);
    const croppedSimilarity = padded.similarityData && new Uint8Array(outW * outH * 4);
    const srcData = padded.data;

    for (let y = 0; y < outH; y++) {
      const srcY = y + padOut;
      if (srcY < 0 || srcY >= padded.height) {
        continue;
      }
      const srcRow = (srcY * padded.width + padOut) * 4;
      const dstRow = y * outW * 4;
      const len = min(outW, max(0, padded.width - padOut)) * 4;
      cropped.set(srcData.subarray(srcRow, srcRow + len), dstRow);
      if (padded.similarityData) {
        croppedSimilarity.set(padded.similarityData.subarray(srcRow, srcRow + len), dstRow);
      }
    }

    let croppedSplines;

    if (padded.allSplines) {
      croppedSplines = padded.allSplines.map(spline =>
        spline.map(([x, y]) => [x - padOut + 0.5, y - padOut + 0.5])
      );
    }

    return {
      data: cropped,
      width: outW,
      height: outH,
      similarityData: croppedSimilarity,
      splines: croppedSplines
    };
  }

  const result = runPipeline(src, outH, threshold, similarity, renderMode, doOpt, outputSimilarityMask);

  let splines;

  if (result.allSplines) {
    splines = result.allSplines.map(spline =>
      spline.map(([x, y]) => [x + 0.5, y + 0.5])
    );
  }

  return {
    data: result.data,
    width: result.width,
    height: result.height,
    similarityData: result.similarityData,
    splines: splines
  };
}

Artificial.Spectrum.PixelArt.Upscaling.Depixelizer._scaleImage = scaleImage;
