AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Assets.BriefComponent extends PAA.Practice.Asset.Bitmap.BriefComponent
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
  
  copySourceAssets: ->
    sourceAssetClasses = @bitmap.constructor.copySourceAssets()
    return [] unless sourceAssetClasses.length
    
    projectClass = @bitmap.constructor.projectClass()
    project = _.find @projects(), (project) -> project instanceof projectClass
    
    _.filter project.assets(), (asset) =>
      _.find sourceAssetClasses, (sourceAssetClass) => asset instanceof sourceAssetClass
  
  events: ->
    super(arguments...).concat
      'click .copy-button': @onClickCopyButton

  onClickCopyButton: (event) ->
    sourceAsset = @currentData()
    sourceBitmap = sourceAsset.bitmap()
    layer = sourceBitmap.layers[0]

    destinationBitmap = @bitmap.bitmap()

    action = new AM.Document.Versioning.Action @bitmap.id()
    
    if sourceBitmap.references
      for reference in sourceBitmap.references
        continue if _.find destinationBitmap.references, (existingReference) => existingReference.image.url is reference.image.url
        
        addReferenceAction = new LOI.Assets.VisualAsset.Actions.AddReferenceByUrl @bitmap.id(), destinationBitmap, reference.image.url, reference
        AM.Document.Versioning.executePartialAction destinationBitmap, addReferenceAction
        action.append addReferenceAction
    
    pixels = []
    
    for x in [0...layer.width]
      for y in [0...layer.height]
        pixels.push layer.getPixel(x, y) or {x, y}
    
    @bitmap._setPixels pixels, action
