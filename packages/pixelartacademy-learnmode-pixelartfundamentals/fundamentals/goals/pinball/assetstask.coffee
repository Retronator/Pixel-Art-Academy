AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.AssetsTask extends PAA.Learning.Task.Automatic
  @unlockedAssets: -> throw new AE.NotImplementedException "Asset task must return an array of assets it unlocks."
  
  @onActive: ->
    # Add assets to the project if needed.
    activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    project = PAA.Practice.Project.documents.findOne activeProjectId
    
    for unlockedAsset in @unlockedAssets()
      unlockedAssetId = unlockedAsset.id()
      continue if _.find project.assets, (asset) => asset.id is unlockedAssetId

      do (unlockedAsset) =>
        bitmapId = await @_createAssetBitmap unlockedAsset
        
        PAA.Practice.Project.documents.update activeProjectId,
          $push:
            assets:
              id: unlockedAsset.id()
              type: unlockedAsset.type()
              bitmapId: bitmapId
          
  @_createAssetBitmap: (asset) ->
    new Promise (resolve, reject) =>
      # Load all the images.
      imageUrls = asset.imageUrls()
      imageUrls = [imageUrls] unless _.isArray imageUrls
      
      imagePromises = for imageUrl in imageUrls
        new Promise (resolve) =>
          image = new Image
          image.addEventListener 'load', =>
            resolve image
          ,
            false
          
          # Initiate the loading.
          image.src = Meteor.absoluteUrl imageUrl
          
      # Load the macintosh palette.
      macintoshPalette = await new Promise (resolve) =>
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
          return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
          computation.stop()
          resolve palette
  
      # Create a bitmap out of the images.
      Promise.all(imagePromises).then (imageResults) =>
        creationTime = new Date()
        width = imageResults[0].width
        height = imageResults[0].height
        
        bitmapData =
          versioned: true
          profileId: LOI.adventure.profileId()
          creationTime: creationTime
          lastEditTime: creationTime
          name: asset.displayName()
          bounds:
            fixed: true
            left: 0
            right: width - 1
            top: 0
            bottom: height - 1
          pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'
          palette:
            _id: macintoshPalette._id
        
        # Create green snake body.
        bitmapData.layers = for imageResult in imageResults
          layer = new LOI.Assets.Bitmap.Layer bitmapData, bitmapData,
            bounds:
              x: 0
              y: 0
              width: width
              height: height
          layer.importImage imageResult, macintoshPalette
          layer.toPlainObject()
        
        resolve LOI.Assets.Bitmap.documents.insert bitmapData
