AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ProjectAssetProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: ->
    return unless projectId = @options.project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne projectId
    
    return unless asset = _.find project.assets, (asset) => asset.id is @options.asset.id()
    return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
    
    # We know the player has changed the bitmap if the history position is not zero.
    return unless bitmap.historyPosition
    
    true

  # Total units

  completedRatio: -> if @completed() then 1 else 0
