AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtGrading

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      flipPaper: AEc.ValueTypes.Trigger

  constructor: ->
    super arguments...

    @active = new ReactiveField false
    @_wasActive = false
    
  onCreated: ->
    super arguments...
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @activeCriterion = new ReactiveField null
    @contentHeight = new ReactiveField 0
    
    @bitmap = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()
    
    @bitmapObject = new ComputedField =>
      @bitmap()
    ,
      (a, b) => a is b
      
    @pixelArtGrading = new ComputedField =>
      return unless bitmap = @bitmapObject()
      new PAG bitmap
    
    @engineComponent = new PAG.EngineComponent
      pixelArtGrading: => @pixelArtGrading()
    
    @pixelArtGradingProperty = new ComputedField =>
      @bitmap()?.properties?.pixelArtGrading
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      @deactivate() unless @desktop.focusedMode()
  
  onRendered: ->
    super arguments...
    
    @content$ = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @contentHeight @content$.outerHeight()
    
    @_resizeObserver.observe @content$[0]
    
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
    
  onBackButton: ->
    return unless @activeCriterion()
    
    @activeCriterion null
    
    # Inform that we've handled the back button.
    true
    
  editorDrawComponents: -> [
    @engineComponent
  ]
  
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
    
  contentPlaceholderStyle: ->
    height: "#{@contentHeight()}px"
    
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
      
    onCreated: ->
      super arguments...
      
      @pixelArtGrading = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
    
    load: ->
      criterion = @data()
      
      _.nestedProperty @pixelArtGrading.pixelArtGradingProperty(), criterion.propertyPath
    
    save: (value) ->
      criterion = @data()
      
      pixelArtGradingProperty = EJSON.clone @pixelArtGrading.pixelArtGradingProperty()
      
      if value
        _.nestedProperty pixelArtGradingProperty, criterion.propertyPath, {}
        
      else
        _.deleteNestedProperty pixelArtGradingProperty, criterion.propertyPath
      
      asset = @pixelArtGrading.interface.getLoaderForActiveFile()?.asset()
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), asset, 'pixelArtGrading', pixelArtGradingProperty
      
      asset.executeAction updatePropertyAction
