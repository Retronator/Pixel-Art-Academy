AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball

class Goal.AssetsTask extends Goal.Task
  @unlockedAssets: -> throw new AE.NotImplementedException "Asset task must return an array of assets it unlocks."
  
  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId

    # The player must have drawn the first of the unlocked assets.
    requiredAssetId = @unlockedAssets()[0].id()
    
    return unless asset = _.find project.assets, (asset) => asset.id is requiredAssetId
    return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
    
    # We know the player has changed the bitmap if the history position is not zero.
    bitmap.historyPosition
