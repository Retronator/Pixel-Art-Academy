AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ProjectAssetProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

  completed: ->
    projects = @options.project.getProjects()
    return unless projects.length
    
    for project in projects
      continue unless asset = _.find project.assets, (asset) => asset.id is @options.asset.id()
      continue unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
    
      # We know the player has changed the bitmap if the history position is not zero.
      return true if bitmap.historyPosition
    
    false

  completedRatio: -> if @completed() then 1 else 0
