AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Resource.BitmapStringPixels extends TutorialBitmap.Resource.Pixels
  constructor: (@bitmapString) ->
    super arguments...
    
  pixels: ->
    return @_pixels if @_pixels
    
    @_pixels = []

    # We need to quit if we get an empty string since the regex would never quit on it.
    return @_pixels unless @bitmapString?.length
    
    regExp = /^\|?(.*)/gm
    lines = (match[1] while match = regExp.exec @bitmapString)
    
    for line, y in lines
      for character, x in line
        # Skip spaces (empty pixel).
        continue if character is ' '

        # We support up to 16 colors denoted in hex notation.
        ramp = parseInt character, 16
        
        @_pixels.push
          x: x
          y: y
          paletteColor:
            ramp: ramp
            shade: 0
    
    @_pixels
