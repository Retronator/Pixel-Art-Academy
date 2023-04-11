AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialBitmap extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @create: (profileId, tutorial, assetId) ->
    # Create the bitmap.
    @_createBitmap(profileId).then (bitmapId) =>
      @reset assetId, bitmapId
  
      assets = tutorial.assetsData()
    
      # Add the asset.
      assets.push
        id: @id()
        type: @type()
        bitmapId: bitmapId
    
      # Update tutorial assets in the read-only state.
      tutorial.state 'assets', assets
    
  @_createBitmap: (profileId) ->
    size = @fixedDimensions()
    
    creationTime = new Date()
    
    bitmapData =
      versioned: true
      profileId: profileId
      creationTime: creationTime
      lastEditTime: creationTime
      bounds:
        left: 0
        right: size.width - 1
        top: 0
        bottom: size.height - 1
        fixed: true
      name: @displayName()
      pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor', 'directColor'
      layers: []

    if references = @references?()
      bitmapData.references = []
  
      for reference in references
        # Allow sending in just the reference URL.
        if _.isString reference
          reference =
            image:
              url: reference
    
        imageUrl = reference.image.url
    
        # Ensure we have an image with this URL.
        imageId = LOI.Assets.Image.documents.findOne(url: imageUrl)?._id
        imageId ?= LOI.Assets.Image.documents.insert
          url: imageUrl
          profileId: profileId
          lastEditTime: creationTime
    
        reference.image._id = imageId
    
        bitmapData.references.push reference
      
    @_setBitmapDataPalette(bitmapData).then =>
      bitmapId = LOI.Assets.Bitmap.documents.insert bitmapData

      new Promise (resolve, reject) =>
        Tracker.autorun (computation) =>
          return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
          computation.stop()
          
          addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer @id(), bitmap
          AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, addLayerAction, new Date()
      
          resolve bitmapId

  @_setBitmapDataPalette: (bitmapData) ->
    new Promise (resolve, reject) =>
      if paletteName = @restrictedPaletteName()
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent paletteName
          return unless palette = LOI.Assets.Palette.documents.findOne name: paletteName
          computation.stop()
          
          bitmapData.palette = _.pick palette, '_id'
          resolve()
  
      else if paletteImageUrl = @customPaletteImageUrl()
        paletteImage = new Image
        paletteImage.addEventListener 'load', =>
          imageData = new AM.ReadableCanvas(paletteImage).getFullImageData()

          ramps = []
    
          backgroundColorArray = @backgroundColor()?.toByteArray?()
    
          isBackground = (pixelOffset) ->
            # Treat transparent pixels as background.
            return true unless imageData.data[pixelOffset + 3]
      
            # We're not transparent, so in case we don't have a background color, this can't be a background pixel.
            return unless backgroundColorArray
      
            # Compare in case this pixel matches our background color.
            for attributeOffset in [0..2]
              return unless imageData.data[pixelOffset + attributeOffset] is backgroundColorArray[attributeOffset]
      
            # The match was made, this pixel has background color.
            true
    
          for y in [0...imageData.height]
            rampOffset = y * imageData.width * 4
      
            # We have a ramp if the first pixel is not background.
            continue if isBackground rampOffset
      
            shades = []
      
            for x in [0...imageData.width]
              shadeOffset = rampOffset + x * 4
        
              # We have no more shades after we reach a background pixel.
              break if isBackground shadeOffset
        
              shades.push
                r: imageData.data[shadeOffset] / 255
                g: imageData.data[shadeOffset + 1] / 255
                b: imageData.data[shadeOffset + 2] / 255
      
            ramps.push
              shades: shades
    
          bitmapData.customPalette =
            ramps: ramps
            
          resolve()
    
        paletteImage.src = Meteor.absoluteUrl paletteImageUrl
        
      else if customPalette = @customPalette()
        bitmapData.customPalette = customPalette
        resolve()
