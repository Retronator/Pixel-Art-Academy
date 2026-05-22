AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Assets.BriefComponent extends PAA.Practice.Project.Asset.Bitmap.BriefComponent
  @register 'PixelArtAcademy.Pixeltosh.Programs.Chess.Assets.BriefComponent'
  
  onCreated: ->
    super arguments...
      
    @workbenchSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: PAA.Practice.Project.Workbench
      
      return unless options.timelineId
      
      new LOI.Adventure.Situation options
      
    @projects = new ComputedField =>
      return unless workbenchSituation = @workbenchSituation()
      
      workbenchSituation.things()
  
  copySourceAsset: ->
    return unless sourceAsset = @bitmap.constructor.copySourceAsset()
    
    project = _.find @projects(), (project) -> project instanceof Chess.Project.TwoDimensional
    
    _.find project.assets(), (asset) => asset instanceof sourceAsset
  
  events: ->
    super(arguments...).concat
      'click .copy-button': @onClickCopyButton

  onClickCopyButton: (event) ->
    sourceAsset = @copySourceAsset()
    bitmap = sourceAsset.bitmap()
    layer = bitmap.layers[0]
    
    pixels = []
    
    for x in [0...layer.width]
      for y in [0...layer.height]
        pixels.push layer.getPixel(x, y) or {x, y}
    
    @bitmap._setPixels pixels
