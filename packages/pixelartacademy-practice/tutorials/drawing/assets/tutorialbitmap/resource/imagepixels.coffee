AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Resource.ImagePixels extends TutorialBitmap.Resource.Pixels
  constructor: (@urlOrImage, @options = {}) ->
    super arguments...
    
    @_pixels = new ReactiveField null
    
    if _.isString @urlOrImage
      url = @urlOrImage
  
      # Load pixels directly from the source image.
      image = new Image
      image.addEventListener 'load', =>
        @_pixels @_createPixelsFromImage image
      ,
        false
      
      # Initiate the loading.
      image.src = Meteor.absoluteUrl url
      
    else
      image = @urlOrImage
      @_pixels @_createPixelsFromImage image
      
  pixels: -> @_pixels()

  _createPixelsFromImage: (image) ->
    imageData = new AM.ReadableCanvas(image).getFullImageData()

    @_createPixelsFromImageData imageData

  _createPixelsFromImageData: (imageData) ->
    pixels = []
    
    palette = @options.palette?()

    for x in [0...imageData.width]
      for y in [0...imageData.height]
        pixelOffset = (x + y * imageData.width) * 4

        # Skip transparent pixels.
        continue unless imageData.data[pixelOffset + 3]
        
        r = imageData.data[pixelOffset] / 255
        g = imageData.data[pixelOffset + 1] / 255
        b = imageData.data[pixelOffset + 2] / 255
        
        # This is a full pixel. If we have a palette, find the closest palette color.
        if palette
          paletteColor = palette.closestPaletteColorFromRGB r, g, b
          pixels.push {x, y, paletteColor}
        
        else
          pixels.push
            x: x
            y: y
            directColor: {r, g, b}

    pixels
