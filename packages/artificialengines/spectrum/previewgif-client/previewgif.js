// preview-gif 1.0.2 by Harrison Liddiard <omniaura5@gmail.com> (http://harrisonliddiard.com)
// Library to download and display only the first frame of an animated GIF.
// Used under BSD-3-Clause license from https://github.com/liddiard/preview-gif

// Build a worker from an anonymous function body
// http://stackoverflow.com/a/19201292/2487925
// something like workify (https://github.com/shama/workerify) would be
// prettier, but it requires a bunch of dependencies and looks like it
// might not work with bundlers other than browserify
var blobURL;

function initializeBlobURL() {
  if (blobURL) return;

  blobURL = URL.createObjectURL(new Blob(['(',

    function () {
      var read = function (data, index) {
        return data.charCodeAt(index) & 0xff;
      }

      // Safari does not support console.log for web workers.
      // Chrome does not support alert for web workers
      // WTF?
      var debug = function (msg) {
        var enabled = true;
        if (enabled && typeof console !== 'undefined' && console.log) {
          console.log(msg);
        }
      }

      // Nicolas Perriault (nperriault@gmail.com) via http://stackoverflow.com/a/7372816
      var base64Encode = function (str) {
        var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var out = "", i = 0, len = str.length, c1, c2, c3;
        while (i < len) {
          c1 = str.charCodeAt(i++) & 0xff;
          if (i == len) {
            out += CHARS.charAt(c1 >> 2);
            out += CHARS.charAt((c1 & 0x3) << 4);
            out += "==";
            break;
          }
          c2 = str.charCodeAt(i++);
          if (i == len) {
            out += CHARS.charAt(c1 >> 2);
            out += CHARS.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
            out += CHARS.charAt((c2 & 0xF) << 2);
            out += "=";
            break;
          }
          c3 = str.charCodeAt(i++);
          out += CHARS.charAt(c1 >> 2);
          out += CHARS.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
          out += CHARS.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
          out += CHARS.charAt(c3 & 0x3F);
        }
        return out;
      }

      // Note: The code below was borrowed from Dean McNamee's omggif and slightly modified.
      //
      //
      // (c) Dean McNamee <dean@gmail.com>, 2013.
      //
      // https://github.com/deanm/omggif
      //
      // Permission is hereby granted, free of charge, to any person obtaining a copy
      // of this software and associated documentation files (the "Software"), to
      // deal in the Software without restriction, including without limitation the
      // rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
      // sell copies of the Software, and to permit persons to whom the Software is
      // furnished to do so, subject to the following conditions:
      //
      // The above copyright notice and this permission notice shall be included in
      // all copies or substantial portions of the Software.
      //
      // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
      // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
      // IN THE SOFTWARE.
      //
      // omggif is a JavaScript implementation of a GIF 89a encoder and decoder,
      // including animation and compression.  It does not rely on any specific
      // underlying system, so should run in the browser, Node, or Plask.
      var readImage = function (buffer, limit) {
        var p = 0;

        // Header
        if (read(buffer, p++) !== 0x47 || // G
          read(buffer, p++) !== 0x49 || // I
          read(buffer, p++) !== 0x46 || // F
          read(buffer, p++) !== 0x38 || // 8
          read(buffer, p++) !== 0x39 || // 9
          read(buffer, p++) !== 0x61) { // a
          throw "Invalid GIF 89a header.";
        }

        // - Logical Screen Descriptor.
        var width = read(buffer, p++) | read(buffer, p++) << 8;
        var height = read(buffer, p++) | read(buffer, p++) << 8;
        var pf0 = read(buffer, p++);  // <Packed Fields>.
        var global_palette_flag = pf0 >> 7;
        var num_global_colors_pow2 = pf0 & 0x7;
        var num_global_colors = 1 << (num_global_colors_pow2 + 1);
        var background = read(buffer, p++);
        read(buffer, p++);  // Pixel aspect ratio

        var global_palette_offset = null;

        if (global_palette_flag) {
          global_palette_offset = p;
          p += num_global_colors * 3;  // Seek past palette.
        }

        while (p < buffer.length) {
          var b = read(buffer, p++);
          if (b == 0x21) { //  Graphics Control Extension Block
            switch (read(buffer, p++)) {
              case 0xff:  // Application specific block
                // Try if it's a Netscape block (with animation loop counter).
                if (read(buffer, p) !== 0x0b ||  // 21 FF already read, check block size.
                  // NETSCAPE2.0
                  read(buffer, p + 1) == 0x4e && read(buffer, p + 2) == 0x45 && read(buffer, p + 2) == 0x54 &&
                  read(buffer, p + 4) == 0x53 && read(buffer, p + 5) == 0x43 && read(buffer, p + 6) == 0x41 &&
                  read(buffer, p + 7) == 0x50 && read(buffer, p + 8) == 0x45 && read(buffer, p + 9) == 0x32 &&
                  read(buffer, p + 10) == 0x2e && read(buffer, p + 11) == 0x30 &&
                  // Sub-block
                  read(buffer, p + 12) == 0x03 && read(buffer, p + 13) == 0x01 && read(buffer, p + 16) == 0) {
                  p += 14;
                  p++;  // Skip terminator.
                } else {  // We don't know what it is, just try to get past it.
                  p += 12;
                  while (true) {  // Seek through subblocks.
                    var block_size = read(buffer, p++);
                    if (block_size === 0) break;
                    p += block_size;
                  }
                }
                break;

              case 0xf9:  // Graphics Control Extension
                if (read(buffer, p++) !== 0x4 || read(buffer, p + 4) !== 0)
                  throw "Invalid graphics extension block.";
                var pf1 = read(buffer, p++);
                delay = read(buffer, p++) | read(buffer, p++) << 8;
                transparent_index = read(buffer, p++);
                if ((pf1 & 1) === 0) transparent_index = null;
                disposal = pf1 >> 2 & 0x7;
                p++;  // Skip terminator.
                break;

              case 0xfe:  // Comment Extension.
                while (true) {  // Seek through subblocks.
                  var block_size = read(buffer, p++);
                  if (block_size === 0) break;
                  p += block_size;
                }
                break;

              default:
                throw "Unknown graphic control label: 0x" + read(buffer, p - 1).toString(16);
            }
          } else if (b == 0x2c) { // Image descriptor
            break;
          }
        }

        p += 10; // Jump to image buffer

        while (true) {
          var block_size = read(buffer, p++);

          if (block_size === 0 && p <= limit) {
            debug(" [Worker] found frame offset at byte " + p);
            var frame_data = "data:image/gif;base64," + base64Encode(buffer.substring(0, p));
            return frame_data;
          }

          p += block_size;

          if (p >= limit) {
            // Range was too small. Fetch more bytes.
            debug(" Worker needs to fetch more bytes " + p);
            return -1;
          }
        }
      }

      // Returns either -1 if more bytes need to be fetched or offset for first frame
      onmessage = function (e) {
        var buffer = e.data.buffer;
        var limit = e.data.limit;
        try {
          var response = readImage(buffer, limit); // either -1 (fetch more bytes) or encoded frame data
          postMessage(response);
        } catch (e) {
          // Error reading buffer due to bad headers or data
          postMessage(-2);
        }
      };

    }.toString(),

    ')()'], {type: 'application/javascript'}));
}

function PreviewGIF(url, callback) {

  // Cachebuster for Safari so it does not reuse the cached 206 partial response for
  // subsequent range requests
  var cb = function() {
    return '?cb=' + (Math.floor(Math.random() * 1000000));
  };

  // TODO: add support for IE by using XDomain object
  var _processGIF = function(url, callback) {
    var buffer = '';
    var range_start = 0,
      range_end = 100000,
      range_increment = 25000;

    initializeBlobURL();
    var worker = new Worker(blobURL); // should each request have its own worker?

    // Setup XHR request
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url + cb());
    xhr.setRequestHeader('Range', 'bytes=' + range_start + '-' + range_end);

    if (xhr.overrideMimeType) { // not supported by ie
      xhr.overrideMimeType('text/plain; charset=x-user-defined');
    }

    // Pass response to web worker for processing
    xhr.onload = function() {
      buffer += xhr.responseText;

      worker.onmessage = function(event) {
        if (event.data == -1) { // Fetch more bytes
          // Fetch more bytes
          range_start = range_end + 1;
          range_end += range_increment;
          xhr.abort();
          xhr.open('GET', url + cb());
          xhr.setRequestHeader('Range', 'bytes=' + range_start + '-' + range_end);
          xhr.send();
        } else if (event.data == -2) { // Error occured while reading
          callback({
            type: 'DECODE_ERROR',
            message: 'Error reading image from ' + url
          });
        } else { // Preview for first frame!
          var preview = event.data;
          callback(null, preview);
        }
      };

      worker.postMessage({
        buffer: buffer,
        limit: range_end
      });
    };

    // Error while making request
    xhr.onerror = function() {
      callback({
        type: 'REQUEST_ERROR',
        message: 'Error requesting image from ' + url
      });
    }

    xhr.send();
  };

  _processGIF(url, callback);

}

Artificial.Spectrum.PreviewGIF = PreviewGIF;
