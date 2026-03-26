AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball

class Goal.AssetsTask extends Goal.Task
  @unlockedAssets: -> throw new AE.NotImplementedException "Asset task must return an array of assets it unlocks."
  
  @onActive: ->
    # Add assets to the project if needed.
    activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    project = PAA.Practice.Project.documents.findOne activeProjectId

    createAssetBitmapPromises = for unlockedAsset in @unlockedAssets()
      unlockedAssetId = unlockedAsset.id()
      continue if _.find project.assets, (asset) => asset.id is unlockedAssetId

      do (unlockedAsset) =>
        new Promise (resolve) =>
          bitmapId = await @_createAssetBitmap unlockedAsset
          
          resolve
            id: unlockedAsset.id()
            type: unlockedAsset.type()
            bitmapId: bitmapId
    
    return unless createAssetBitmapPromises.length
    
    Promise.all(createAssetBitmapPromises).then (newAssets) =>
      PAA.Practice.Project.documents.update activeProjectId,
        $push:
          assets:
            $each: newAssets
        $set:
          lastEditTime: new Date
          
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
  
  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId

    # The player must have drawn the first of the unlocked assets.
    requiredAssetId = @unlockedAssets()[0].id()
    
    return unless asset = _.find project.assets, (asset) => asset.id is requiredAssetId
    return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
    
    # We know the player has changed the bitmap if the history position is not zero.
    bitmap.historyPosition
