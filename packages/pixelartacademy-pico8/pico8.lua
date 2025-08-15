--- @diagnostic disable:lowercase-global

----------------------------------------
--- CREDITS
----------------------------------------
-- Created by Peabnuts123 (@peabnuts123)
-- GitHub: https://github.com/peabnuts123/pico8-emmylua-definitions
-- No license as PICO-8 is proprietary software.
-- Please include this credit if you include this in your project 🙂
-- Feedback and submissions welcome!

----------------------------------------
--- TYPE DEFINITIONS
----------------------------------------

--- @class Color:number Any number between 0-15. Specifies a color in the pico8 color palette
--- @class SpriteFlag:number Any number between 0-7
--- @class Button:number Any number between 0-5
--- @class Player:number Any number between 0-7
--- @class Coroutine:table A PICO-8 coroutine, created by `cocreate()`

----------------------------------------
--- THE GAME LOOP
----------------------------------------

--- Copies the graphics buffer to the screen, then synchronizes to the next frame at 30 frames per second.
--- API Reference: https://pico-8.fandom.com/wiki/Flip
function flip() end


----------------------------------------
--- GRAPHICS
----------------------------------------

--- Sets the camera offset in the [draw state](https://pico-8.fandom.com/wiki/DrawState).
--- API Reference: https://pico-8.fandom.com/wiki/Camera
--- @param x? number The x offset, in pixels, to subtract from future draw coordinates. (default 0)
--- @param y? number The y offset, in pixels, to subtract from future draw coordinates. (default 0)
function camera(x, y) end

--- Draws a circle shape, without fill.
--- API Reference: https://pico-8.fandom.com/wiki/Circ
--- @param x number The x coordinate of the center of the circle.
--- @param y number The y coordinate of the center of the circle.
--- @param r? number The radius of the circle, in pixels. If omitted, the radius will be 4.
--- @param col? Color The color of the circle and fill. If omitted, the color from the [draw state](https://pico-8.fandom.com/wiki/DrawState) is used.
function circ(x, y, r, col) end

--- Draws a filled-in circle shape.
--- API Reference: https://pico-8.fandom.com/wiki/Circfill
--- @param x number The x coordinate of the center of the circle.
--- @param y number The y coordinate of the center of the circle.
--- @param r? number The radius of the circle, in pixels. If omitted, the radius will be 4.
--- @param col? Color The color of the circle and fill. If omitted, the color from the [draw state](https://pico-8.fandom.com/wiki/DrawState) is used.
function circfill(x, y, r, col) end

--- Sets the clipping region in the [draw state](https://pico-8.fandom.com/wiki/DrawState).
--- API Reference: https://pico-8.fandom.com/wiki/Clip
--- @param x? number The x coordinate of the upper left corner of the clipping rectangle.
--- @param y? number The y coordinate of the upper left corner of the clipping rectangle.
--- @param w? number The width of the clipping rectangle, in pixels.
--- @param h? number The height of the clipping rectangle, in pixels.
function clip(x, y, w, h) end

--- Resets the clipping region in the [draw state](https://pico-8.fandom.com/wiki/DrawState) to be the entire screen, and returns the previous state as 4 return values x, y, w, h.
--- @return number x, number y, number w, number h The bounds of the previous clipping region
function clip() end

--- Clears the graphics buffer with the specified color.
--- API Reference: https://pico-8.fandom.com/wiki/Cls
--- @param color? Color A color to use for the background. The default is 0 (black).
function cls(color) end

--- Sets the pen color in the [draw state](https://pico-8.fandom.com/wiki/DrawState).
--- API Reference: https://pico-8.fandom.com/wiki/Color
--- @overload fun() : number Does something or other
--- @param col? Color The color number. Default is 6 (light gray).
--- @overload fun(a: number, b: number) : number Does something or other
function color(col) end
--- Sets the pen color in the [draw state](https://pico-8.fandom.com/wiki/DrawState) to the default value (6, light gray), and returns the previous value.
--- @return Color previous_color The previous pen color in the [draw state](https://pico-8.fandom.com/wiki/DrawState)
function color() end

--- Sets the left-margin cursor position for `print()`.
--- API Reference: https://pico-8.fandom.com/wiki/Cursor
--- @param x? number The x coordinate of the upper left corner of the line. The default is 0.
--- @param y? number The y coordinate of the upper left corner of the line. The default is 0.
function cursor(x, y) end
--- Sets the left-margin cursor position for `print()` and also sets the pen color.
--- API Reference: https://pico-8.fandom.com/wiki/Cursor
--- @param x? number The x coordinate of the upper left corner of the line. The default is 0.
--- @param y? number The y coordinate of the upper left corner of the line. The default is 0.
--- @param col Color The palette index to set the pen color to.
function cursor(x, y, col) end

--- Gets the value of a flag of a sprite.
--- API Reference: https://pico-8.fandom.com/wiki/Fget
--- @param n number The sprite number.
--- @param f SpriteFlag The flag index (0-7).
--- @return boolean flag The flag value.
function fget(n, f) end
--- Gets the value of all flags of a sprite.
--- API Reference: https://pico-8.fandom.com/wiki/Fget
--- @param n number The sprite number.
--- @return number flags A number that represents all of the flags as a bit field. See API Reference for more details.
function fget(n) end

--- Sets the fill pattern.
--- The pattern is a bitfield, a single number that represents a 4x4 pixel pattern. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Fillp
--- @param pat number A bitfield representing the fill pattern to use.
function fillp(pat) end
--- Clear the current fill pattern.
--- API Reference: https://pico-8.fandom.com/wiki/Fillp
function fillp() end

--- Sets the value of a flag of a sprite.
--- API Reference: https://pico-8.fandom.com/wiki/Fset
--- @param n number The sprite number.
--- @param f SpriteFlag The flag index (0-7).
--- @param v boolean The value.
function fset(n, f, v) end
--- Sets the value of all flags of a sprite.
--- API Reference: https://pico-8.fandom.com/wiki/Fset
--- @param n number The sprite number.
--- @param v number The values, a bit field of all flags. See API Reference for more details.
function fset(n, v) end

--- Draws a line between two points.
--- API Reference: https://pico-8.fandom.com/wiki/Line
--- @param x0? number The x coordinate of the start of the line. If omitted, the x coordinate of the end of the previous line is used, or 0 if no previous line has been drawn.
--- @param y0? number The y coordinate of the start of the line. If omitted, the y coordinate of the end of the previous line is used, or 0 if no previous line has been drawn.
--- @param x1? number The x coordinate of the end of the line.
--- @param y1? number The y coordinate of the end of the line.
--- @param col? Color The color of the line. If omitted, the color from the [draw state](https://pico-8.fandom.com/wiki/DrawState) is used. This also sets the color in the draw state.
function line(x0, y0, x1, y1, col) end

--- Changes the [draw state](https://pico-8.fandom.com/wiki/DrawState) so all instances of a given color are replaced with a new color.
--- API Reference: https://pico-8.fandom.com/wiki/Pal
--- @param c0 Color The number of the original color to replace.
--- @param c1 Color The number of the new color to use instead.
--- @param p? number 0 to modify the palette used by draw operations, 1 to modify the palette for the screen already drawn. The default is 0.
function pal(c0, c1, p) end
--- Reset the entire color palette, including transparency settings.
--- API Reference: https://pico-8.fandom.com/wiki/Pal
function pal() end

--- Change the transparency of a color in the [draw state](https://pico-8.fandom.com/wiki/DrawState) for subsequent draw calls.
--- API Reference: https://pico-8.fandom.com/wiki/Palt
--- @param col Color The number of the color to modify.
--- @param t boolean If true, treat this color as transparent. If false, treat this color as opaque.
function palt(col, t) end
--- Reset all transparency settings of the entire color palette. Does NOT reset colors (use `pal()` for this).
--- API Reference: https://pico-8.fandom.com/wiki/Palt
function palt() end

--- Gets the color value of a pixel at the given coordinates.
--- It will return 0 (black) if given coordinates outside the range (0-127,0-127).
--- API Reference: https://pico-8.fandom.com/wiki/Pget
--- @param x number The x coordinate [0-127].
--- @param y number The y coordinate [0-127].
--- @return Color color The color index of the given pixel.
function pget(x, y) end

--- Prints a string of characters to the screen.
--- Given only a Lua string, print uses the cursor location and pen color of the current [draw state](https://pico-8.fandom.com/wiki/DrawState). The cursor position is moved to the next line, potentially scrolling the entire display up by a line.
--- API Reference: https://pico-8.fandom.com/wiki/Print
--- @param str? string The string of characters to print.
--- @param x? number The x coordinate of the upper left corner to start printing.
--- @param y? number The y coordinate of the upper left corner to start printing.
--- @param col? Color The color to use for the text.
function print(str, x, y, col) end

--- Sets a pixel in the graphics buffer.
--- API Reference: https://pico-8.fandom.com/wiki/Pset
--- @param x number The x coordinate.
--- @param y number The y coordinate.
--- @param c? Color The color value. If not specified, uses the current color of the [draw state](https://pico-8.fandom.com/wiki/DrawState).
function pset(x, y, c) end

--- Draws an empty rectangle shape.
--- API Reference: https://pico-8.fandom.com/wiki/Rect
--- @param x0 number The x coordinate of the upper left corner.
--- @param y0 number The y coordinate of the upper left corner.
--- @param x1 number The x coordinate of the lower right corner.
--- @param y1 number The y coordinate of the lower right corner.
--- @param col? Color The color of the rectangle border. If omitted, the color from the draw state is used.
function rect(x0, y0, x1, y1, col) end

--- Draws a filled-in rectangle shape.
--- API Reference: https://pico-8.fandom.com/wiki/Rectfill
--- @param x0 number The x coordinate of the upper left corner.
--- @param y0 number The y coordinate of the upper left corner.
--- @param x1 number The x coordinate of the lower right corner.
--- @param y1 number The y coordinate of the lower right corner.
--- @param col? Color The color of the rectangle and fill. If omitted, the color from the draw state is used.
function rectfill(x0, y0, x1, y1, col) end

--- Gets the color value of a pixel on the sprite sheet.
--- It will return 0 (black) if given coordinates outside the range (0-127,0-127).
--- API Reference: https://pico-8.fandom.com/wiki/Sget
--- @param x number The x coordinate on the sprite sheet.
--- @param y number The y coordinate on the sprite sheet.
--- @return Color color The color index of the given pixel
function sget(x, y) end

--- Draws a sprite, or a range of sprites, on the screen.
--- API Reference: https://pico-8.fandom.com/wiki/Spr
--- @param n number The sprite number. When drawing a range of sprites, this is the upper-left corner.
--- @param x number The x coordinate.
--- @param y number The y coordinate.
--- @param w? number The width of the range, as a number of sprites. Non-integer values may be used to draw partial sprites. The default is 1.0.
--- @param h? number The height of the range, as a number of sprites. Non-integer values may be used to draw partial sprites. The default is 1.0.
--- @param flip_x? boolean If true, the sprite is drawn inverted left to right. The default is false.
--- @param flip_y? boolean If true, the sprite is drawn inverted top to bottom. The default is false.
function spr(n, x, y, w, h, flip_x, flip_y) end

--- Sets the color value of a pixel on the sprite sheet.
--- API Reference: https://pico-8.fandom.com/wiki/Sset
--- @param x number The x coordinate on the sprite sheet.
--- @param y number The y coordinate on the sprite sheet.
--- @param c? Color The color value to set. If unspecified, the color of the current [draw state](https://pico-8.fandom.com/wiki/DrawState) will be used.
function sset(x, y, c) end

--- Draws a rectangle of pixels from the sprite sheet, optionally stretching the image to fit a rectangle on the screen.
--- API Reference: https://pico-8.fandom.com/wiki/Sspr
--- @param sx number The x coordinate of the upper left corner of the rectangle in the sprite sheet.
--- @param sy number The y coordinate of the upper left corner of the rectangle in the sprite sheet.
--- @param sw number The width of the rectangle in the sprite sheet, as a number of pixels.
--- @param sh number The height of the rectangle in the sprite sheet, as a number of pixels.
--- @param dx? number The x coordinate of the upper left corner of the rectangle area of the screen.
--- @param dy? number The y coordinate of the upper left corner of the rectangle area of the screen.
--- @param dw? number The width of the rectangle area of the screen. The default is to match the image width (sw).
--- @param dh? number The height of the rectangle area of the screen. The default is to match the image height (sh).
--- @param flip_x? boolean If true, the image is drawn inverted left to right. The default is false.
--- @param flip_y? boolean If true, the image is drawn inverted top to bottom. The default is false.
function sspr(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y) end

--- Draws a textured line between two points, sampling the map for texture data.
--- API Reference: https://pico-8.fandom.com/wiki/Tline
--- @param x0 number The x coordinate of the start of the line.
--- @param y0 number The y coordinate of the start of the line.
--- @param x1 number The x coordinate of the end of the line.
--- @param y1 number The y coordinate of the end of the line.
--- @param mx number The x coordinate to begin sampling the map, expressed in (fractional) map tiles.
--- @param my number The y coordinate to begin sampling the map, expressed in (fractional) map tiles.
--- @param mdx? number The amount to add to mx after each pixel is drawn, expressed in (fractional) map tiles. Default is 1/8 (move right one map pixel).
--- @param mdy? number The amount to add to mx after each pixel is drawn, expressed in (fractional) map tiles. Default is 0 (a horizontal line).
function tline(x0, y0, x1, y1, mx, my, mdx, mdy) end


----------------------------------------
--- TABLES
----------------------------------------

--- Adds an element to the end of a sequence in a table.
--- API Reference: https://pico-8.fandom.com/wiki/Add
--- @param tbl table The table.
--- @param v any The value to add.
--- @param i? number The index for the value to be inserted. Defaults to the end of the sequence.
function add(tbl, v, i ) end

--- Returns an iterator for all non-nil items in a sequence in a table, for use with for...in.
--- API Reference: https://pico-8.fandom.com/wiki/All
--- @param tbl table The table to iterate.
--- @return function iterator The iterator.
function all(tbl) end

--- Deletes the first occurrence of a value from a sequence in a table.
--- API Reference: https://pico-8.fandom.com/wiki/Del
--- @param tbl table
--- @param v any The value to match and remove.
function del(tbl, v) end

--- Removes the element at the given index of a sequence in a table.
--- API Reference: https://pico-8.fandom.com/wiki/Deli
--- @param tbl table The table.
--- @param i number The index for the value to be removed.
function deli(tbl, i) end

--- Calls a function for each element in a sequence in a table.
--- API Reference: https://pico-8.fandom.com/wiki/Foreach
--- @generic T
--- @param tbl table<number,T> The table.
--- @param f fun(item: T) The function to call. The function should accept an element as its sole argument.
function foreach(tbl, f) end

--- A stateless iterator of key-value pairs for all elements in a table.
--- Used internally by `pairs()` and `ipairs()`.
--- API Reference: https://pico-8.fandom.com/wiki/Next
--- @param tbl table The table.
--- @param key? any The current key.
--- @return function iterator The iterator.
function next(tbl, key) end

--- Returns an iterator of index-value pairs for all elements in a table, for use with `for...in`.
--- API Reference: https://pico-8.fandom.com/wiki/IPairs
--- @param tbl table The table.
--- @return function iterator The iterator.
function ipairs(tbl) end

--- Creates a table from the given parameters.
--- API Reference: https://pico-8.fandom.com/wiki/Pack
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param args ... The parameters.
--- @return table table A table with all parameters stored sequentially into keys [1], [2], etc.
function pack(...) end

--- Returns an iterator of key-value pairs for all elements in a table, for use with `for...in`.
--- API Reference: https://pico-8.fandom.com/wiki/Pairs
--- @param tbl table The table.
--- @return function iterator The iterator.
function pairs(tbl) end

--- Returns the elements from the given table as a tuple.
--- @param tbl table The table to unpack.
--- @param i? number First index to unpack. Default is 1.
--- @param j? number Last index to unpack. Default is `#tbl`.
function unpack(tbl, i, j) end


----------------------------------------
--- INPUT
----------------------------------------

--- Tests if a button is being pressed at this moment.
--- Buttons:
---   - 0: Left
---   - 1: Right
---   - 2: Up
---   - 3: Down
---   - 4: O
---   - 5: X
--- API Reference: https://pico-8.fandom.com/wiki/Btn
--- @param i? Button The button number (0-5).
--- @param p? Player The player number (0-7).
--- @return boolean button_state true if the button is currently pressed
function btn(i, p) end
--- Gets a bitfield of all button states for players 0 and 1.
--- Player 0's buttons are represented by bits 0 through 5 (the least significant bits), and player 1's buttons are represented by bits 8 through 13 (the most significant bits).
--- See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Btn
--- @return number button_states A bitfield representing the button states for players 0 and 1.
function btn() end

--- Tests if a button has just been pressed, with keyboard-style repeating.
--- API Reference: https://pico-8.fandom.com/wiki/Btnp
--- @param i Button The button number.
--- @param p Player The player number.
--- @return boolean button_state true only if the button is currently pressed and was not pressed in the previous frame (i.e. it was just pressed)
function btnp(i, p) end
--- Gets a bitfield of all button states for players 0 and 1, whether they were pressed in the last frame, with keyboard-style repeating.
--- Player 0's buttons are represented by bits 0 through 5 (the least significant bits), and player 1's buttons are represented by bits 8 through 13 (the most significant bits).
--- API Reference: https://pico-8.fandom.com/wiki/Btnp
--- @return number button_states A bitfield representing the button states for players 0 and 1, whether they were pressed or repeated in the last frame.
function btnp() end


----------------------------------------
--- SOUND
----------------------------------------

--- Plays a music pattern, or stops playing.
--- API Reference: https://pico-8.fandom.com/wiki/Music
--- @param n number The pattern number to start playing (0-63), or -1 to stop playing music.
--- @param fade_len? number If not 0, fade in (or out) the music volume over a duration, given as a number of milliseconds.
--- @param channel_mask? number A bitfield indicating which of the four sound channels should be reserved for music. The default is 0 (no channels reserved).
function music(n, fade_len, channel_mask) end

--- Plays a sound effect.
--- API Reference: https://pico-8.fandom.com/wiki/Sfx
--- @param n number The number of the sound effect to play (0-63), -1 to stop playing sound on the given channel, or -2 to release the sound of the given channel from looping.
--- @param channel? number The channel to use for the sound effect (0-3). The default is -1, which chooses an available channel automatically. Can be -2 to stop playing the given sound effect on any channels it plays on.
--- @param offset? number The note position in the sound effect to start playing (0-31). The default is 0 (the beginning).
--- @param length number The number of notes in the sound effect to play (0-31). The default is to play the entire sound effect.
function sfx(n, channel, offset, length) end

----------------------------------------
--- MAP
----------------------------------------

--- Draws a portion of the map to the graphics buffer.
--- API Reference: https://pico-8.fandom.com/wiki/Map
--- @param cel_x number The column location of the map cell in the upper left corner of the region to draw, where 0 is the leftmost column.
--- @param cel_y number The row location of the map cell in the upper left corner of the region to draw, where 0 is the topmost row.
--- @param sx number The x coordinate of the screen to place the upper left corner.
--- @param sy number The y coordinate of the screen to place the upper left corner.
--- @param cel_w number The number of map cells wide in the region to draw.
--- @param cel_h number The number of map cells tall in the region to draw.
--- @param layer? number If specified, only draw sprites that have flags set for every bit in this value (a bitfield). The default is 0 (draw all sprites).
function map(cel_x, cel_y, sx, sy, cel_w, cel_h, layer) end

--- Gets the sprite number assigned to a cell on the map.
--- API Reference: https://pico-8.fandom.com/wiki/Mget
--- @param x number The column (x) coordinate of the cell.
--- @param y number The row (y) coordinate of the cell.
--- @return number sprite_number The number of the sprite assigned to cell at map coordinate cell (x, y)
function mget(x, y) end

--- Sets a cell on the map to a new sprite number.
--- API Reference: https://pico-8.fandom.com/wiki/Mset
--- @param x number The column (x) coordinate of the cell.
--- @param y number The row (y) coordinate of the cell.
--- @param v number The new sprite number to store.
function mset(x, y, v) end


----------------------------------------
--- MEMORY
----------------------------------------

--- Store a region of memory in the cartridge file, or another cartridge file.
--- API Reference: https://pico-8.fandom.com/wiki/Cstore
--- @param dest_addr number The address of the first byte of the destination in the cartridge.
--- @param source_addr number The address of the first byte in memory to copy.
--- @param len number The length of the memory region to copy, as a number of bytes.
--- @param filename? string If specified, the filename of a cartridge to which data is written. The default is to write to the currently loaded cartridge.
function cstore(dest_addr, source_addr, len, filename) end

--- Copies a region of memory to another location in memory.
--- API Reference: https://pico-8.fandom.com/wiki/Memcpy
--- @param dest_addr number The address of the first byte of the destination.
--- @param source_addr number The address of the first byte of the memory to copy.
--- @param len number The length of the memory region to copy, as a number of bytes.
function memcpy(dest_addr, source_addr, len) end

--- Writes a byte value to every address in a region of memory.
--- API Reference: https://pico-8.fandom.com/wiki/Memset
--- @param dest_addr number The address of the first memory location to write.
--- @param val number The byte value to write.
--- @param len number The length of the region of memory to write, as a number of bytes.
function memset(dest_addr, val, len) end

--- Reads one or more bytes from contiguous memory locations starting at `addr`.
--- You may also use the `@` operator instead of `peek()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Peek
--- @param addr number The address of the first memory location.
--- @param n? number The number of bytes to return. (1 by default, 8192 max.)
--- @return ... bytes The bytes, one return value per byte.
function peek(addr, n) end

--- Reads one or more 16-bit values from contiguous groups of two consecutive memory locations.
--- You may also use the `%` operator instead of `peek2()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Peek2
--- @param addr number The address of the first memory location.
--- @param n? number The number of values to return. (1 by default, 8192 max.)
--- @return ... bytes The bytes, one return value per byte.
function peek2(addr, n) end

--- Reads one or more 32-bit fixed-point number values from contiguous groups of four consecutive memory locations.
--- You may also use the `$` operator instead of `peek4()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Peek4
--- @param addr number The address of the first memory location.
--- @param n? number The number of values to return. (1 by default, 8192 max.)
--- @return ... bytes The bytes, one return value per byte.
function peek4(addr, n) end

--- Writes one or more bytes to contiguous memory locations.
--- API Reference: https://pico-8.fandom.com/wiki/Poke
--- @param addr number The address of the first memory location.
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param values ... The byte values to write to memory. If these are omitted, a single zero is written.
function poke(addr, ...) end

--- Writes one or more 16-bit values to contiguous groups of two consecutive memory locations.
--- API Reference: https://pico-8.fandom.com/wiki/Poke2
--- @param addr number The address of the first memory location.
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param values ... The 16-bit values to write to memory. If these are omitted, a zero is written to the first 2 bytes.
function poke2(addr, ...) end

--- Writes one or more 32-bit fixed-point PICO-8 number values to contiguous groups of four consecutive memory locations.
--- API Reference: https://pico-8.fandom.com/wiki/Poke4
--- @param addr number The address of the first memory location.
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param values ... The 32-bit values to write to memory. If these are omitted, a zero is written to the first 4 bytes.
function poke4(addr, ...) end

--- Loads a region of data from the cartridge, or from another cartridge, into memory.
--- API Reference: https://pico-8.fandom.com/wiki/Reload
--- @param dest_addr number The address of the first byte of the destination in memory.
--- @param source_addr number The address of the first byte in the cartridge data.
--- @param len number The length of the memory region to copy, as a number of bytes.
--- @param filename? string If specified, the filename of a cartridge from which to read data. The default is to read from the currently loaded cartridge.
function reload(dest_addr, source_addr, len, filename) end

--- Load all data from the cartridge into memory. Equivalent to `reload(0, 0, 0x4300)`.
--- API Reference: https://pico-8.fandom.com/wiki/Reload
function reload() end


----------------------------------------
--- MATH
----------------------------------------

--- Returns the absolute value of a number.
--- API Reference: https://pico-8.fandom.com/wiki/Abs
--- @param num number The number.
--- @return number result The absolute value of `num`.
function abs(num) end

--- Calculates the arctangent of dy/dx, the angle formed by the vector on the unit circle. The result is adjusted to represent the full circle.
--- API Reference: https://pico-8.fandom.com/wiki/Atan2
--- @param dx number The horizontal component.
--- @param dy number The vertical component.
--- @return number result The arctangent of `dy/dx`.
function atan2(dx, dy) end

--- Calculates the bitwise AND of two numbers.
--- You may also use the `&` operator instead of `band()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Band
--- @param a number The first number.
--- @param b number The second number.
--- @return number result The bitwise AND of `a` and `b`.
function band(a, b) end

--- Calculates the bitwise NOT of a number.
--- You may also use the `~` operator instead of `bnot()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Bnot
--- @param num number The number.
--- @return number result The bitwise NOT of `num`.
function bnot(num) end

--- Calculates the bitwise OR of two numbers.
--- You may also use the `|` operator instead of `bor()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Bor
--- @param a number The first number.
--- @param b number The second number.
--- @return number result The bitwise OR of `a` and `b`.
function bor(a, b) end

--- Calculates the bitwise XOR (exclusive or) of two numbers.
--- You may also use the `^^` operator instead of `bxor()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Bxor
--- @param a number The first number.
--- @param b number The second number.
--- @return number result The bitwise XOR of `a` and `b`.
function bxor(a, b) end

--- Calculates the cosine of an angle.
--- NOTE: PICO-8 measures the angle in a CLOCKWISE direction on the Cartesian plane. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Cos
--- @param angle number The angle, using a full circle range of 0.0-1.0 measured clockwise (0.0 to the right).
--- @return number result The cosine of angle `angle`.
function cos(angle) end

--- Returns the next highest integer (the "ceiling") of a number.
--- @param num number The number.
--- @return number result The ceil of `num`.
function ceil(num) end

--- Returns the integer portion (the "floor") of a number.
--- API Reference: https://pico-8.fandom.com/wiki/Flr
--- @param num number The number.
--- @return number result The floor of `num`.
function flr(num) end

--- Returns the maximum of two numbers.
--- API Reference: https://pico-8.fandom.com/wiki/Max
--- @param a number The first number.
--- @param b? number The second number. (default 0)
--- @return number result The max of `a` and `b`.
function max(a, b) end

--- Returns the middle of three numbers. Also useful for clamping.
--- @param a number The first number.
--- @param b number The second number.
--- @param c number The third number.
--- @return number result The middle number of `a`, `b`, and `c`.
function mid(a, b, c) end

--- Returns the minimum of two numbers.
--- @param a number The first number.
--- @param b? number The second number. (default 0)
--- @return number result The smaller of `a` and `b`.
function min(a, b) end

--- Generates a random number between 0 and the given maximum exclusive.
--- API Reference: https://pico-8.fandom.com/wiki/Rnd
--- @param max? number The range, non-inclusive. Defaults to 1.
--- @return number random_number The random number.
function rnd(max) end

--- Returns a random element from a 1-based table sequence.
--- API Reference: https://pico-8.fandom.com/wiki/Rnd
--- @param tbl table The table.
--- @return any random_element The random element of `tbl`.
function rnd(tbl) end

--- Returns the sign of a number, 1 for positive, -1 for negative.
--- NOTE: `sgn(0)` will return 1, not 0 as might be common on other platforms.
--- API Reference: https://pico-8.fandom.com/wiki/Sgn
--- @param num number The number to determine the sign of.
--- @return number result The sign of `num` (either -1 or 1).
function sgn(num) end

--- Shifts the bits of a number to the left.
--- You may also use the `<<` operator instead of `shl()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Shl
--- @param num number The number.
--- @param bits number The number of bits to shift.
--- @return number result The result of shifting `num` to the left by `bits` bits.
function shl(num, bits) end

--- Shifts the bits of a number to the right.
--- `shr()` performs an "arithmetic shift", which means that the sign of the number is preserved. See `lshr()` for a logical shift.
--- You may also use the `>>` operator instead of `shr()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Shr
--- @param num number The number.
--- @param bits number The number of bits to shift.
--- @return number result The result of shifting `num` to the right (arithmetic) by `bits` bits.
function shr(num, bits) end

--- Shifts the bits of a number to the right, using logical shift.
--- `lshr()` performs a "logical shift", which shifts all of the raw bits of the number, filling the highest bits with zeroes. See `shr()` for an arithmetic shift.
--- You may also use the `>>>` operator instead of `lshr()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Lshr
--- @param num number The number.
--- @param bits number The number of bits to shift.
--- @return number result The result of shifting `num` to the right (logical) by `bits` bits.
function lshr(num, bits) end

--- Rotates the bits of a number to the right.
--- You may also use the `>><` operator instead of `rotr()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Rotr
--- @param num number The number.
--- @param bits number The number of bits to rotate.
--- @return number result The result of rotating `num` to the right by `bits` bits.
function rotr(num, bits) end

--- Rotates the bits of a number to the left.
--- You may also use the `<<>` operator instead of `rotl()`. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Rotl
--- @param num number The number.
--- @param bits number The number of bits to rotate.
--- @return number result The result of rotating `num` to the left by `bits` bits.
function rotl(num, bits) end

--- Calculates the sine of an angle.
--- NOTE: PICO-8 measures the angle in a CLOCKWISE direction on the Cartesian plane. See API Reference for more details.
--- API Reference: https://pico-8.fandom.com/wiki/Sin
--- @param angle number The angle, using a full circle range of 0.0-1.0 measured clockwise (0.0 to the right).
--- @return number result The sine of angle `angle`.
function sin(angle) end

--- Calculates the square root of a number.
--- API Reference: https://pico-8.fandom.com/wiki/Sqrt
--- @param num number The number. Must be positive.
--- @return number result The sqaure root of `num`.
function sqrt(num) end

--- Initializes the random number generator with an explicit seed value.
--- API Reference: https://pico-8.fandom.com/wiki/Srand
--- @param val number The seed value.
function srand(val) end


----------------------------------------
--- CARTRIDGE DATA
----------------------------------------

--- Sets up cartridge data for the cart.
--- API Reference: https://pico-8.fandom.com/wiki/Cartdata
--- @param id string A string that is likely to be unique across all PICO-8 carts.
function cartdata(id) end

--- Gets a value from persistent cartridge data.
--- API Reference: https://pico-8.fandom.com/wiki/Dget
--- @param index number The index of the value, 0 to 63.
--- @return number value The value.
function dget(index) end

--- Sets a value in persistent cartridge data.
--- API Reference: https://pico-8.fandom.com/wiki/Dset
--- @param index number The index of the value.
--- @param value number The new value to set.
function dset(index, value) end


----------------------------------------
--- COROUTINES
----------------------------------------

--- Creates a coroutine from a function.
--- API Reference: https://pico-8.fandom.com/wiki/Cocreate
--- @param func fun() The coroutine function. Takes no arguments and returns no value.
--- @return Coroutine coroutine Instance of created coroutine, for use with `coresume()`, `costatus()`, etc.
function cocreate(func) end

-- @NOTE @TODO it looks like `yield()` and `coresume()` do pass and return values in both directions (like other languages), but
-- this doesn't seem to be documented. I've omitted it here even though my tests seem to show an argument
-- passed to `yield()` (e.g. `yield("hello")`) is returned as a second value from `coresume()`
-- e.g.
-- ```lua
-- function my_routine()
--   for i=1,10 do
--     yield(i)
--   end
-- end

-- local thread = cocreate(my_routine)

-- function _update()
--   local success, value = coresume(thread)
--   print("value: " .. value) -- prints 1, 2, 3 etc.
-- end
-- ```

--- Starts a coroutine, or resumes a suspended coroutine.
--- API Reference: https://pico-8.fandom.com/wiki/Coresume
--- @param cor Coroutine The coroutine, as created by `cocreate()`.
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param args ... The arguments to pass to the coroutine's function or the coroutine's subsequent yields.
--- @return boolean success true if the given coroutine was active (suspended) when coresume() was called, or false if it was given a dead coroutine (and no code was executed by resuming).
--- @return string? failure_reason (not always guaranteed) a string describing an exception that caused the routine to die unexpectedly, e.g. "attempt to index a nil value". A full stack trace can also be obtained by passing the dead coroutine to `trace()`.
function coresume(cor, ...) end

--- Tests a coroutine and returns a string representing its status.
--- API Reference: https://pico-8.fandom.com/wiki/Costatus
--- @param cor Coroutine The coroutine to test.
--- @return string status The status of the coroutine. One of: `"running"` `"suspended"` or `"dead"`.
function costatus(cor) end

--- Yields control back to the caller from within a coroutine.
--- API Reference: https://pico-8.fandom.com/wiki/Yield
--- @return ... args Arg values passed to `coresume()`
function yield() end

----------------------------------------
--- VALUES AND OBJECTS
----------------------------------------

--- Gets the character corresponding to an ordinal (numeric) value.
--- API Reference: https://pico-8.fandom.com/wiki/Chr
--- @param ord number The ordinal value to be converted to a single-character string.
--- @return string char The character represented by numeric value `ord`.
function chr(ord) end

--- Gets the metatable for a table.
--- API Reference: https://pico-8.fandom.com/wiki/Getmetatable
--- @param tbl table The table.
--- @return table metatable The metatable of `tbl`.
function getmetatable(tbl) end

--- Gets the ordinal (numeric) version of a character in a string.
--- API Reference: https://pico-8.fandom.com/wiki/Ord
--- @param str string The string whose character is to be converted to an ordinal.
--- @param index? number The index of the character in the string. Default is 1, the first character.
--- @return number ord The numeric representation of the character.
function ord(str, index) end

--- Compare two tables, bypassing metamethods.
--- API Reference: https://pico-8.fandom.com/wiki/Rawequal
--- @param tbl1 table A table to compare.
--- @param tbl2 table Another table to compare.
--- @return boolean are_equal Whether the two tables are equal, using native equality checks instead of  `__eq`.
function rawequal(tbl1, tbl2) end

--- Read a table member, bypassing metamethods.
--- API Reference: https://pico-8.fandom.com/wiki/Rawget
--- @param tbl table The table whose member to read.
--- @param member any The member to read.
--- @return any value Value of the table member, using native lookups intead of `__index` or `__newindex`.
function rawget(tbl, member) end

--- Get the length of a table, bypassing metamethods
--- API Reference: https://pico-8.fandom.com/wiki/Rawlen
--- @param tbl table The table whose length to retrieve.
--- @return number length The length of the table, using native length checks instead of `__len`.
function rawlen(tbl) end

--- Write to a table member, bypassing metamethods.
--- API Reference: https://pico-8.fandom.com/wiki/Rawset
--- @param tbl table The table whose member to modify.
--- @param member any The member to modify.
--- @param value any The member's new value.
function rawset(tbl, member, value) end

--- Selects from the given parameters.
--- If index is a number, returns all parameters starting at index `index`.
--- @param index number Index to return parameters from
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param args ... The parameters.
--- @return ... parameters Parameters passed in, starting from index `index`
function select( index, ... ) end
--- Selects from the given parameters.
--- If index is `#`, returns the number of parameters passed.
--- @param index string The string `#`
--- @diagnostic disable-next-line: undefined-doc-param Want to document varargs param more than specifying its type with `@vararg`
--- @param args ... The parameters.
--- @return number num_parameters The number of parameters passed in.
function select( index, ... ) end

--- Updates the metatable for a table.
--- API Reference: https://pico-8.fandom.com/wiki/Setmetatable
--- @param tbl table The table whose metatable to modify.
--- @param metatbl table The new metatable.
function setmetatable(tbl, metatbl) end

--- Split a string into a table of elements delimited by the given separator (defaults to ",").
--- API Reference: https://pico-8.fandom.com/wiki/Split
--- @param str string The string.
--- @param separator? string The separator (defaults to ",").
--- @param convert_numbers? boolean When convert_numbers is true, numerical tokens are stored as numbers (defaults to true).
--- @return table string_parts The parts of the string as a table of elements, after splitting by `delimiter`.
function split( str, separator, convert_numbers) end

--- Gets the substring of a string.
--- `from` and `to` indices are inclusive.
--- API Reference: https://pico-8.fandom.com/wiki/Sub
--- @param str string The string.
--- @param from number The starting index, counting from 1 at the left, or -1 at the right.
--- @param to? number The ending index, counting from 1 at the left, or -1 at the right. (default -1)
--- @return string substring The substring.
function sub(str, from, to) end

--- Converts a string representation of a decimal, hexadecimal, or binary number to a number value.
--- API Reference: https://pico-8.fandom.com/wiki/Tonum
--- @param str string The string.
--- @return number number The numeric value of the string `str`. Returns [no value](https://wiki.facepunch.com/gmod/no_value) (effectively `nil`) if the string does not represent a number. See API Reference for more details.
function tonum(str) end

--- Converts a non-string value to a string representation.
--- API Reference: https://pico-8.fandom.com/wiki/Tostr
--- @param val any The value to convert.
--- @param usehex? boolean If true, uses 32-bit unsigned fixed point hexadecimal notation for number values. The default is to use concise decimal notation for number values.
--- @return string string The string representation of `val`.
function tostr(val, usehex) end

--- Returns the basic type of a given value as a string.
--- API Reference: https://pico-8.fandom.com/wiki/Type
--- @param v any The value whose type to test.
--- @return string type Type of `v` as a string e.g. `"number"`
function type(v) end


----------------------------------------
--- TIME
----------------------------------------

--- Returns the amount of time since PICO-8 was last started, as a (fractional) number of seconds.
--- API Reference: https://pico-8.fandom.com/wiki/Time
--- @return number time Amount of time since PICO-8 was last started, as a (fractional) number of seconds.
function time() end

--- Same as `time()`.
--- Returns the amount of time since PICO-8 was last started, as a (fractional) number of seconds.
--- API Reference: https://pico-8.fandom.com/wiki/Time
--- @return number time Amount of time since PICO-8 was last started, as a (fractional) number of seconds.
function t() end


----------------------------------------
--- SYSTEM
----------------------------------------

--- Executes an administrative command from within a program.
--- API Reference: https://pico-8.fandom.com/wiki/Extcmd
--- @param cmd string The command name, as a string. See API Reference for possible command names.
function extcmd(cmd) end

--- Loads a cartridge.
--- API Reference: https://pico-8.fandom.com/wiki/Load
--- @param filename string Either the name of the cartridge file, a BBS cart ID in the form "#mycartid123", or "@clip" to load a cartridge from the system clipboard copied from the BBS.
--- @param breadcrumb? string When called from within a cart with this parameter, this adds an item to the pause menu to return to the original cart.
--- @param param? string An arbitrary string value that can be accessed by the loaded cart using `stat(6)`.
function load(filename, breadcrumb, param) end

--- Adds a custom item to the PICO-8 menu.
--- API Reference: https://pico-8.fandom.com/wiki/Menuitem
--- @param index number The item index, a number between 1 and 5.
--- @param label string The label text of the menu item to add or change.
--- @param callback fun() A Lua function to call when the user selects this menu item.
function menuitem(index, label, callback) end
--- Remove a previously added custom menu item.
--- API Reference: https://pico-8.fandom.com/wiki/Menuitem
--- @param index number The item index, a number between 1 and 5.
function menuitem(index) end

--- Runs the current cartridge from the start of the program.
--- API Reference: https://pico-8.fandom.com/wiki/Run
--- @param str? string A "breadcrumb" string, as if passed by a calling cartridge.
function run(str) end

----------------------------------------
--- DEBUGGING
----------------------------------------

--- Causes a runtime error if a conditional expression is false.
--- API Reference: https://pico-8.fandom.com/wiki/Assert
--- @param cond boolean The conditional expression to assert.
--- @param message? string The message to print when the assertion fails.
function assert(cond, message) end

--- Prints a string to a console window that is running PICO-8, or to a file or the clipboard.
--- API Reference: https://pico-8.fandom.com/wiki/Printh
--- @param str string The string to print.
--- @param filename? string The name of a file to append the output, instead of printing to the console. If this is the string `@clip`, the message replaces the contents of the system clipboard instead of writing to a file.
--- @param overwrite? boolean If `filename` is provided and is the name of a file and overwrite is true, this overwrites the file. The default is false, which appends the message to the end of the file.
function printh(str, filename, overwrite) end

--- Returns information about the current runtime environment.
--- API Reference: https://pico-8.fandom.com/wiki/Stat
--- @param id number The ID of the information to return. See API Reference for details on available IDs.
function stat(id) end

--- Stops the program's execution and returns to the PICO-8 command prompt, optionally printing a message.
--- API Reference: https://pico-8.fandom.com/wiki/Stop
--- @param message? string An optional message to print before stopping.
--- @param x? number The x coordinate of the upper left corner to start printing.
--- @param y? number The y coordinate of the upper left corner to start printing.
--- @param col? Color The color to use for the text.
function stop(message, x, y, col) end

--- Returns a description of the current or a specified call stack as a string.
--- API Reference: https://pico-8.fandom.com/wiki/Trace
--- @param coroutine? Coroutine Optionally get the stack trace for a coroutine. Defaults to the current one or the main thread.
--- @param message? string Adds the given string to the top of the trace report. Defaults to blank.
--- @param skip? number Number of levels of the stack to skip. Defaults to 1, to skip the trace() call's own level.
function trace(coroutine, message, skip) end
--- Returns a description of the current call stack as a string.
--- API Reference: https://pico-8.fandom.com/wiki/Trace
--- @param message? string Adds the given string to the top of the trace report. Defaults to blank.
--- @param skip? number Number of levels of the stack to skip. Defaults to 1, to skip the trace() call's own level.
function trace(message, skip) end
