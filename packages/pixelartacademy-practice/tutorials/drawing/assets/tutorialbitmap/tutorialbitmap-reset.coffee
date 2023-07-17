AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @reset: (assetId, bitmapId) ->
    # Build the original state.
    assetClass = PAA.Practice.Project.Asset.getClassForId assetId
  
    resetPixels = (pixels) =>
      bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

      # Mark all transparent pixels for removal (add pixel with just coordinates).
      for x in [0...bitmap.bounds.width]
        for y in [0...bitmap.bounds.height]
          pixels.push {x, y} unless _.find pixels, (pixel) => pixel.x is x and pixel.y is y
      
      # Replace the layer pixels in this bitmap.
      strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @id(), bitmap, [0], pixels
      AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
      # Clear the history.
      AMu.Document.Versioning.clearHistory bitmap
  
    if bitmapString = assetClass.bitmapString()
      resetPixels assetClass.createPixelsFromBitmapString bitmapString
  
    else if imageUrl = assetClass.imageUrl()
      # Note: We're on the client and need to send a callback that will execute once the image has loaded.
      assetClass.createPixelsFromImageUrl(imageUrl).then (pixels) => resetPixels pixels
  
    else
      # No data was provided so we assume the starting image should be empty.
      resetPixels []

    if references = assetClass.references?()
      # Rebuild references but use the existing image data.
      bitmapData = LOI.Assets.Bitmap.documents.findOne bitmapId
      newReferences = []
  
      for reference in references
        # Allow sending in just the reference URL.
        imageUrl = if _.isString reference then reference else reference.image.url
        reference = {} if _.isString reference
    
        existingReference = _.find bitmapData.references, (bitmapReference) => bitmapReference.image.url is imageUrl
    
        newReferences.push _.defaults
          image: _.pick existingReference.image, ['_id', 'url']
        ,
          reference
      
      LOI.Assets.Bitmap.documents.update bitmapId,
        $set:
          references: newReferences
    
      LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId

  @createPixelsFromBitmapString: (bitmapString) ->
    # We need to quit if we get an empty string since the regex would never quit on it.
    return [] unless bitmapString?.length

    regExp = /^\|?(.*)/gm
    lines = (match[1] while match = regExp.exec bitmapString)

    pixels = []

    for line, y in lines
      for character, x in line
        # Skip spaces (empty pixel).
        continue if character is ' '

        # We support up to 16 colors denoted in hex notation.
        ramp = parseInt character, 16

        pixels.push
          x: x
          y: y
          paletteColor:
            ramp: ramp
            shade: 0

    pixels

  @createPixelsFromImageUrl: (url) ->
    new Promise (resolve, reject) =>
      # Load pixels directly from the source image.
      image = new Image
      image.addEventListener 'load', =>
        resolve @createPixelsFromImage image
      ,
        false
  
      # Initiate the loading.
      image.src = Meteor.absoluteUrl url

  @createPixelsFromImage: (image) ->
    imageData = new AM.ReadableCanvas(image).getFullImageData()

    @createPixelsFromImageData imageData

  @createPixelsFromImageData: (imageData) ->
    pixels = []

    for x in [0...imageData.width]
      for y in [0...imageData.height]
        pixelOffset = (x + y * imageData.width) * 4

        # Skip transparent pixels.
        continue unless imageData.data[pixelOffset + 3]

        pixels.push
          x: x
          y: y
          directColor:
            r: imageData.data[pixelOffset] / 255
            g: imageData.data[pixelOffset + 1] / 255
            b: imageData.data[pixelOffset + 2] / 255

    pixels
