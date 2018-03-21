PAA = PixelArtAcademy

#{cubicBezier} = require 'bresenham-zingl'

# HACK: Temporary use of original Bresenham implementation until the NPM package is fixed.

setPixel = null

`
  /**
   * Bresenham Curve Rasterizing Algorithms
   * @author  Zingl Alois
   * @date    17.12.2014
   * @version 1.3
   * @url     http://members.chello.at/easyfilter/bresenham.html
   */

  function assert(a) {
    if (!a) console.log("Assertion failed in bresenham.js "+a);
    return a;
  }

  function plotLine(x0, y0, x1, y1)
  {
    var dx =  Math.abs(x1-x0), sx = x0<x1 ? 1 : -1;
    var dy = -Math.abs(y1-y0), sy = y0<y1 ? 1 : -1;
    var err = dx+dy, e2;                                   /* error value e_xy */

    for (;;){                                                          /* loop */
      setPixel(x0,y0);
      if (x0 == x1 && y0 == y1) break;
      e2 = 2*err;
      if (e2 >= dy) { err += dy; x0 += sx; }                        /* x step */
      if (e2 <= dx) { err += dx; y0 += sy; }                        /* y step */
    }
  }

  function plotQuadBezierSeg(x0, y0, x1, y1, x2, y2)
  {                                  /* plot a limited quadratic Bezier segment */
    var sx = x2-x1, sy = y2-y1;
    var xx = x0-x1, yy = y0-y1, xy;               /* relative values for checks */
    var dx, dy, err, cur = xx*sy-yy*sx;                            /* curvature */

    assert(xx*sx <= 0 && yy*sy <= 0);       /* sign of gradient must not change */

    if (sx*sx+sy*sy > xx*xx+yy*yy) {                 /* begin with shorter part */
      x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;       /* swap P0 P2 */
    }
    if (cur != 0) {                                         /* no straight line */
      xx += sx; xx *= sx = x0 < x2 ? 1 : -1;                /* x step direction */
      yy += sy; yy *= sy = y0 < y2 ? 1 : -1;                /* y step direction */
      xy = 2*xx*yy; xx *= xx; yy *= yy;               /* differences 2nd degree */
      if (cur*sx*sy < 0) {                                /* negated curvature? */
        xx = -xx; yy = -yy; xy = -xy; cur = -cur;
      }
      dx = 4.0*sy*cur*(x1-x0)+xx-xy;                  /* differences 1st degree */
      dy = 4.0*sx*cur*(y0-y1)+yy-xy;
      xx += xx; yy += yy; err = dx+dy+xy;                     /* error 1st step */
      do {
        setPixel(x0,y0);                                          /* plot curve */
        if (x0 == x2 && y0 == y2) return;       /* last pixel -> curve finished */
        y1 = 2*err < dx;                       /* save value for test of y step */
        if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; }      /* x step */
        if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; }      /* y step */
      } while (dy < 0 && dx > 0);        /* gradient negates -> algorithm fails */
    }
    plotLine(x0,y0, x2,y2);                       /* plot remaining part to end */
  }

  function plotQuadBezier(x0, y0, x1, y1, x2, y2)
  {                                          /* plot any quadratic Bezier curve */
    var x = x0-x1, y = y0-y1, t = x0-2*x1+x2, r;

    if (x*(x2-x1) > 0) {                              /* horizontal cut at P4? */
      if (y*(y2-y1) > 0)                           /* vertical cut at P6 too? */
        if (Math.abs((y0-2*y1+y2)/t*x) > Math.abs(y)) {      /* which first? */
          x0 = x2; x2 = x+x1; y0 = y2; y2 = y+y1;            /* swap points */
        }                            /* now horizontal cut at P4 comes first */
      t = (x0-x1)/t;
      r = (1-t)*((1-t)*y0+2.0*t*y1)+t*t*y2;                       /* By(t=P4) */
      t = (x0*x2-x1*x1)*t/(x0-x1);                       /* gradient dP4/dx=0 */
      x = Math.floor(t+0.5); y = Math.floor(r+0.5);
      r = (y1-y0)*(t-x0)/(x1-x0)+y0;                  /* intersect P3 | P0 P1 */
      plotQuadBezierSeg(x0,y0, x,Math.floor(r+0.5), x,y);
      r = (y1-y2)*(t-x2)/(x1-x2)+y2;                  /* intersect P4 | P1 P2 */
      x0 = x1 = x; y0 = y; y1 = Math.floor(r+0.5);        /* P0 = P4, P1 = P8 */
    }
    if ((y0-y1)*(y2-y1) > 0) {                          /* vertical cut at P6? */
      t = y0-2*y1+y2; t = (y0-y1)/t;
      r = (1-t)*((1-t)*x0+2.0*t*x1)+t*t*x2;                       /* Bx(t=P6) */
      t = (y0*y2-y1*y1)*t/(y0-y1);                       /* gradient dP6/dy=0 */
      x = Math.floor(r+0.5); y = Math.floor(t+0.5);
      r = (x1-x0)*(t-y0)/(y1-y0)+x0;                  /* intersect P6 | P0 P1 */
      plotQuadBezierSeg(x0,y0, Math.floor(r+0.5),y, x,y);
      r = (x1-x2)*(t-y2)/(y1-y2)+x2;                  /* intersect P7 | P1 P2 */
      x0 = x; x1 = Math.floor(r+0.5); y0 = y1 = y;        /* P0 = P6, P1 = P7 */
    }
    plotQuadBezierSeg(x0,y0, x1,y1, x2,y2);                  /* remaining part */
  }

  function plotCubicBezierSeg(x0, y0, x1, y1, x2, y2, x3, y3)
  {                                        /* plot limited cubic Bezier segment */
    var f, fx, fy, leg = 1;
    var sx = x0 < x3 ? 1 : -1, sy = y0 < y3 ? 1 : -1;        /* step direction */
    var xc = -Math.abs(x0+x1-x2-x3), xa = xc-4*sx*(x1-x2), xb = sx*(x0-x1-x2+x3);
    var yc = -Math.abs(y0+y1-y2-y3), ya = yc-4*sy*(y1-y2), yb = sy*(y0-y1-y2+y3);
    var ab, ac, bc, cb, xx, xy, yy, dx, dy, ex, pxy, EP = 0.01;
    /* check for curve restrains */
    /* slope P0-P1 == P2-P3    and  (P0-P3 == P1-P2      or  no slope change)  */
    assert((x1-x0)*(x2-x3) < EP && ((x3-x0)*(x1-x2) < EP || xb*xb < xa*xc+EP));
    assert((y1-y0)*(y2-y3) < EP && ((y3-y0)*(y1-y2) < EP || yb*yb < ya*yc+EP));

    if (xa == 0 && ya == 0)                                /* quadratic Bezier */
      return plotQuadBezierSeg(x0,y0, (3*x1-x0)>>1,(3*y1-y0)>>1, x3,y3);
    x1 = (x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+1;                    /* line lengths */
    x2 = (x2-x3)*(x2-x3)+(y2-y3)*(y2-y3)+1;

    do {                                                /* loop over both ends */
      ab = xa*yb-xb*ya; ac = xa*yc-xc*ya; bc = xb*yc-xc*yb;
      ex = ab*(ab+ac-3*bc)+ac*ac;       /* P0 part of self-intersection loop? */
      f = ex > 0 ? 1 : Math.floor(Math.sqrt(1+1024/x1));   /* calc resolution */
      ab *= f; ac *= f; bc *= f; ex *= f*f;            /* increase resolution */
      xy = 9*(ab+ac+bc)/8; cb = 8*(xa-ya);  /* init differences of 1st degree */
      dx = 27*(8*ab*(yb*yb-ya*yc)+ex*(ya+2*yb+yc))/64-ya*ya*(xy-ya);
      dy = 27*(8*ab*(xb*xb-xa*xc)-ex*(xa+2*xb+xc))/64-xa*xa*(xy+xa);
      /* init differences of 2nd degree */
      xx = 3*(3*ab*(3*yb*yb-ya*ya-2*ya*yc)-ya*(3*ac*(ya+yb)+ya*cb))/4;
      yy = 3*(3*ab*(3*xb*xb-xa*xa-2*xa*xc)-xa*(3*ac*(xa+xb)+xa*cb))/4;
      xy = xa*ya*(6*ab+6*ac-3*bc+cb); ac = ya*ya; cb = xa*xa;
      xy = 3*(xy+9*f*(cb*yb*yc-xb*xc*ac)-18*xb*yb*ab)/8;

      if (ex < 0) {         /* negate values if inside self-intersection loop */
        dx = -dx; dy = -dy; xx = -xx; yy = -yy; xy = -xy; ac = -ac; cb = -cb;
      }                                     /* init differences of 3rd degree */
      ab = 6*ya*ac; ac = -6*xa*ac; bc = 6*ya*cb; cb = -6*xa*cb;
      dx += xy; ex = dx+dy; dy += xy;                    /* error of 1st step */
      exit:
        for (pxy = 0, fx = fy = f; x0 != x3 && y0 != y3; ) {
          setPixel(x0,y0);                                       /* plot curve */
          do {                                  /* move sub-steps of one pixel */
            if (pxy == 0) if (dx > xy || dy < xy) break exit;    /* confusing */
            if (pxy == 1) if (dx > 0 || dy < 0) break exit;         /* values */
            y1 = 2*ex-dy;                    /* save value for test of y step */
            if (2*ex >= dx) {                                   /* x sub-step */
              fx--; ex += dx += xx; dy += xy += ac; yy += bc; xx += ab;
            } else if (y1 > 0) break exit;
            if (y1 <= 0) {                                      /* y sub-step */
              fy--; ex += dy += yy; dx += xy += bc; xx += ac; yy += cb;
            }
          } while (fx > 0 && fy > 0);                       /* pixel complete? */
          if (2*fx <= f) { x0 += sx; fx += f; }                      /* x step */
          if (2*fy <= f) { y0 += sy; fy += f; }                      /* y step */
          if (pxy == 0 && dx < 0 && dy > 0) pxy = 1;      /* pixel ahead valid */
        }
      xx = x0; x0 = x3; x3 = xx; sx = -sx; xb = -xb;             /* swap legs */
      yy = y0; y0 = y3; y3 = yy; sy = -sy; yb = -yb; x1 = x2;
    } while (leg--);                                          /* try other end */
    plotLine(x0,y0, x3,y3);       /* remaining part in case of cusp or crunode */
  }

  function plotCubicBezier(x0, y0, x1, y1, x2, y2, x3, y3)
  {                                              /* plot any cubic Bezier curve */
    var n = 0, i = 0;
    var xc = x0+x1-x2-x3, xa = xc-4*(x1-x2);
    var xb = x0-x1-x2+x3, xd = xb+4*(x1+x2);
    var yc = y0+y1-y2-y3, ya = yc-4*(y1-y2);
    var yb = y0-y1-y2+y3, yd = yb+4*(y1+y2);
    var fx0 = x0, fx1, fx2, fx3, fy0 = y0, fy1, fy2, fy3;
    var t1 = xb*xb-xa*xc, t2, t = new Array(5);
    /* sub-divide curve at gradient sign changes */
    if (xa == 0) {                                               /* horizontal */
      if (Math.abs(xc) < 2*Math.abs(xb)) t[n++] = xc/(2.0*xb);  /* one change */
    } else if (t1 > 0.0) {                                      /* two changes */
      t2 = Math.sqrt(t1);
      t1 = (xb-t2)/xa; if (Math.abs(t1) < 1.0) t[n++] = t1;
      t1 = (xb+t2)/xa; if (Math.abs(t1) < 1.0) t[n++] = t1;
    }
    t1 = yb*yb-ya*yc;
    if (ya == 0) {                                                 /* vertical */
      if (Math.abs(yc) < 2*Math.abs(yb)) t[n++] = yc/(2.0*yb);  /* one change */
    } else if (t1 > 0.0) {                                      /* two changes */
      t2 = Math.sqrt(t1);
      t1 = (yb-t2)/ya; if (Math.abs(t1) < 1.0) t[n++] = t1;
      t1 = (yb+t2)/ya; if (Math.abs(t1) < 1.0) t[n++] = t1;
    }
    for (i = 1; i < n; i++)                         /* bubble sort of 4 points */
      if ((t1 = t[i-1]) > t[i]) { t[i-1] = t[i]; t[i] = t1; i = 0; }

    t1 = -1.0; t[n] = 1.0;                                /* begin / end point */
    for (i = 0; i <= n; i++) {                 /* plot each segment separately */
      t2 = t[i];                                /* sub-divide at t[i-1], t[i] */
      fx1 = (t1*(t1*xb-2*xc)-t2*(t1*(t1*xa-2*xb)+xc)+xd)/8-fx0;
      fy1 = (t1*(t1*yb-2*yc)-t2*(t1*(t1*ya-2*yb)+yc)+yd)/8-fy0;
      fx2 = (t2*(t2*xb-2*xc)-t1*(t2*(t2*xa-2*xb)+xc)+xd)/8-fx0;
      fy2 = (t2*(t2*yb-2*yc)-t1*(t2*(t2*ya-2*yb)+yc)+yd)/8-fy0;
      fx0 -= fx3 = (t2*(t2*(3*xb-t2*xa)-3*xc)+xd)/8;
      fy0 -= fy3 = (t2*(t2*(3*yb-t2*ya)-3*yc)+yd)/8;
      x3 = Math.floor(fx3+0.5); y3 = Math.floor(fy3+0.5);     /* scale bounds */
      if (fx0 != 0.0) { fx1 *= fx0 = (x0-x3)/fx0; fx2 *= fx0; }
      if (fy0 != 0.0) { fy1 *= fy0 = (y0-y3)/fy0; fy2 *= fy0; }
      if (x0 != x3 || y0 != y3)                            /* segment t1 - t2 */
        plotCubicBezierSeg(x0,y0, x0+fx1,y0+fy1, x0+fx2,y0+fy2, x3,y3);
      x0 = x3; y0 = y3; fx0 = fx3; fy0 = fy3; t1 = t2;
    }
  }
`

class PAA.PixelBoy.Apps.StudyPlan.Blueprint.Flowchart
  constructor: (@blueprint) ->
    @$canvas = $('<canvas>')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

  drawToContext: (context) ->
    # Render the connections to our canvas.
    displayScale = @blueprint.display.scale()

    @canvas.width = @blueprint.bounds.width() / displayScale
    @canvas.height = @blueprint.bounds.height() / displayScale

    return unless @canvas.width and @canvas.height

    imageData = @context.getImageData 0, 0, @canvas.width, @canvas.height

    for connection in @blueprint.connections()
      @_drawConnection connection, imageData

    @context.putImageData imageData, 0, 0

    # Render the canvas scaled to the main context.
    context.setTransform 1, 0, 0, 1, 0, 0
    context.imageSmoothingEnabled = false
    context.drawImage @canvas, 0, 0, context.canvas.width, context.canvas.height

  _drawConnection: (connection, imageData) ->
    # Draw the curve.
    bezierPoints = @_createBezierPoints connection
    camera = @blueprint.camera()

    bezierParameters = _.flatten _.map bezierPoints, (point) =>
      # Convert points from canvas to display coordinates.
      point = camera.transformCanvasToDisplay point

      # Convert to integers and return coordinates as an array to feed into the cubicBezier method.
      [Math.floor(point.x), Math.floor(point.y)]

    # HACK: Temporary use of original Bresenham implementation until the NPM package is fixed.
    setPixel = (x, y) => @_paintPixel imageData, x, y
    plotCubicBezier bezierParameters...

    #cubicBezier bezierParameters..., (x, y) => @_paintPixel imageData, x, y

    # Draw the arrowhead

    for segment in [0..2]
      x = bezierParameters[6] - segment

      for y in [bezierParameters[7] - segment..bezierParameters[7] + segment]
        @_paintPixel imageData, x, y

  _paintPixel: (imageData, x, y) ->
    return unless 0 <= x < imageData.width and 0 <= y < imageData.height

    pixelIndex = (x + y * imageData.width) * 4

    # Fill the pixel with line color (124, 180, 212).
    imageData.data[pixelIndex] = 124
    imageData.data[pixelIndex + 1] = 180
    imageData.data[pixelIndex + 2] = 212
    imageData.data[pixelIndex + 3] = 255

  _createBezierPoints: (connection) ->
    {start, end} = connection

    # Make the handle the shortest when a bit ahead of the start.
    deltaX = end.x - (start.x + 10)

    # Make the handle length grow faster going backwards.
    deltaX *= -2 if deltaX < 0

    # Make the handle half the horizontal distance, but instead of linear growth, enforce a minimum length.
    minimumStartingHandleLength = 40
    handleLength = Math.pow(deltaX, 2) / (deltaX + minimumStartingHandleLength) * 0.5 + minimumStartingHandleLength

    # Smooth out the handle towards zero at small distances.
    distance = Math.pow(Math.abs(start.y - end.y) + Math.abs(start.x - end.x), 2)
    handleLength *= distance / (distance + 1000)

    handleLength = Math.max 10, Math.min 300, handleLength

    # Create bezier control points.
    controlStart =
      x: start.x + handleLength
      y: start.y

    controlEnd =
      x: end.x - handleLength
      y: end.y

    [start, controlStart, controlEnd, end]