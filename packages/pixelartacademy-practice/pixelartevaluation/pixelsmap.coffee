PAA = PixelArtAcademy

PAE = PAA.Practice.PixelArtEvaluation

class PAE.PixelsMap
  constructor: ->
    @_pixels = {}

  add: (pixel) ->
    @_pixels[pixel.x] ?= {}
    @_pixels[pixel.x][pixel.y] = pixel

  remove: (pixel) ->
    delete @_pixels[pixel.x]?[pixel.y]

  forEach: (operation) ->
    for x, pixels of @_pixels
      for y, pixel of pixels
        operation pixel

    # Explicit return to avoid result collection.
    return
