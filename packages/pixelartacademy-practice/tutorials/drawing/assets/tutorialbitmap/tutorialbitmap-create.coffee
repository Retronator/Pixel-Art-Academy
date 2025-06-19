AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @create: (tutorial) ->
    @_createBitmapData()
      .then((bitmapData) => @_setBitmapDataReferences bitmapData)
      .then((bitmapData) => @_setBitmapDataPalette bitmapData)
      .then((bitmapData) => @_insertBitmap bitmapData)
      .then((bitmapId) => @_resetAndAddToTutorial tutorial, bitmapId)
      .catch (error) =>
        console.error error
        throw new AE.InvalidOperationException "Could not create tutorial bitmap."
    
  @_createBitmapData: ->
    new Promise (resolve, reject) =>
      size = @fixedDimensions()
      creationTime = new Date()
    
      resolve
        versioned: true
        profileId: LOI.adventure.profileId()
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
        properties: @properties()
      
  @_setBitmapDataReferences: (bitmapData) ->
    new Promise (resolve, reject) =>
      unless references = @references?()
        resolve bitmapData
        return
        
      imagePromises = []
    
      for reference in references
        # Allow sending in just the reference URL.
        imageUrl = if _.isString reference then reference else reference.image.url
      
        do (imageUrl) =>
          # Find the ID of the image with this URL.
          imagePromises.push new Promise (resolve, reject) =>
            Tracker.autorun (computation) ->
              LOI.Assets.Image.forUrl.subscribe imageUrl
              LOI.Assets.Image.forUrl.subscribeContent imageUrl
              return unless image = LOI.Assets.Image.documents.findOne url: imageUrl
              computation.stop()
              
              resolve image
          
      Promise.all(imagePromises).then (imageResults) =>
        bitmapData.references = []
        
        # Merge images into references
        for reference, index in references
          # Allow sending in just the reference URL.
          reference = {} if _.isString reference
          
          bitmapData.references.push _.defaults
            image: _.pick imageResults[index], ['_id', 'url']
          ,
            reference
  
        resolve bitmapData

  @_setBitmapDataPalette: (bitmapData) ->
    new Promise (resolve, reject) =>
      if paletteName = @restrictedPaletteName()
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent paletteName
          return unless palette = LOI.Assets.Palette.documents.findOne name: paletteName
          computation.stop()
          
          bitmapData.palette = _.pick palette, '_id'
          resolve bitmapData
  
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
            
          resolve bitmapData
    
        paletteImage.src = Meteor.absoluteUrl paletteImageUrl
        
      else if customPalette = @customPalette()
        bitmapData.customPalette = customPalette
        resolve bitmapData
        
      else
        resolve bitmapData

  @_insertBitmap: (bitmapData) ->
    new Promise (resolve, reject) =>
      bitmapId = LOI.Assets.Bitmap.documents.insert bitmapData

      Tracker.autorun (computation) =>
        return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
        computation.stop()
        
        @_initializeLayers bitmap
        
        resolve bitmapId

  @_initializeLayers: (bitmap) ->
    addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer @id(), bitmap
    AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, addLayerAction, new Date()
    AMu.Document.Versioning.clearHistory bitmap
  
  @_resetAndAddToTutorial: (tutorial, bitmapId) ->
    # Reset the asset instance.
    assetId = @id()
    asset = tutorial.getAsset @id()
    asset.reset()
  
    # Add to tutorial.
    assets = tutorial.assetsData()
    
    unless tutorialBitmap = _.find assets, (asset) => asset.id is assetId
      tutorialBitmap = id: assetId
      assets.push tutorialBitmap

    _.extend tutorialBitmap,
      type: @type()
      bitmapId: bitmapId
  
    tutorial.state 'assets', assets
