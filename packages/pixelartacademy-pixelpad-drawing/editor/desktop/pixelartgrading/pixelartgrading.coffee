AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      flipPaper: AEc.ValueTypes.Trigger
      
  @CriteriaNames:
    PerfectDiagonals: 'Perfect diagonals'
    SmoothCurves: 'Smooth curves'
    ConsistentLineWidth: 'Consistent line width'

  constructor: ->
    super arguments...

    @active = new ReactiveField false
    @_wasActive = false
    
  onCreated: ->
    super arguments...
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @pixelArtGradingProperty = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset().properties?.pixelArtGrading
    
    @editable = new ComputedField => @pixelArtGradingProperty()?.editable
    
    @criteria = new ComputedField =>
      return unless pixelArtGradingProperty = @pixelArtGradingProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAA.Practice.PixelArtGrading.Criteria
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or pixelArtGradingProperty[criterionProperty]?
        
        criteria.push
          propertyName: criterion
          name: @constructor.CriteriaNames[criterion]
          grade: pixelArtGradingProperty[criterionProperty]?.score
      
      criteria
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      @deactivate() unless @desktop.focusedMode()
      
  activate: ->
    @_changeActive true
    
  deactivate: ->
    @_changeActive false
    
  _changeActive: (value) ->
    @active value
    
    return if value is @_wasActive
    @_wasActive = value
    
    return unless @isRendered()

    Tracker.nonreactive =>
      editor = @interface.getEditorForActiveFile()
      editor.triggerSmoothMovement()

      camera = editor.camera()
      scale = camera.effectiveScale()
      
      paperHeight = @$('.paper').height() / scale
      originDeltaY = paperHeight / 2
      originDeltaY *= -1 unless value
      
      originDataField = camera.originData()
      origin = originDataField.value()
      
      originDataField.value
        x: origin.x
        y: origin.y + originDeltaY

  activeClass: ->
    'active' if @active()
    
  gradePercentage: (value) ->
    return unless value?
    
    "#{Math.floor value * 100}%"
    
  letterGrade: ->
    grade = @pixelArtGradingProperty()?.grade or 0
    PAA.Practice.PixelArtGrading.getLetterGrade grade
  
  events: ->
    super(arguments...).concat
      'click': @onClick
    
  onClick: (event) ->
    return if @active()

    @activate()
    
  class @CriterionEnabled extends AM.DataInputComponent
    @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.CriterionEnabled'
    @register @id()
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox
      @extraComponent = @parentComponent()
      
    onCreated: ->
      super arguments...
      
      @pixelArtGrading = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
    
    load: ->
      criterion = @data()
      
      @pixelArtGrading.pixelArtGradingProperty()[criterion.propertyName]?
    
    save: (value) ->
      criterion = @data()
      
      pixelArtGradingProperty = EJSON.clone @pixelArtGrading.pixelArtGradingProperty()
      
      if value
        pixelArtGradingProperty[criterion.propertyName] = {}
        
      else
        delete pixelArtGradingProperty[criterion.propertyName]
      
      asset = @pixelArtGrading.interface.getLoaderForActiveFile()?.asset()
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), asset, 'pixelArtGrading', pixelArtGradingProperty
      
      asset.executeAction updatePropertyAction
