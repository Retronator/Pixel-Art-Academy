AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtEvaluation

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      lift:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      release:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      open: AEc.ValueTypes.Trigger
      close: AEc.ValueTypes.Trigger
      flipPaper: AEc.ValueTypes.Trigger
      checkmarkOn: AEc.ValueTypes.Trigger
      checkmarkOff: AEc.ValueTypes.Trigger
    
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
      
    @pixelArtEvaluation = new ComputedField =>
      return unless bitmap = @bitmapObject()
      @_pixelArtEvaluation?.destroy()
      @_pixelArtEvaluation = new PAG bitmap
      
    @hoveredCategoryValue = new ReactiveField null

    @hoveredPixel = new ComputedField =>
      pixelCanvas = @interface.getEditorForActiveFile()
      pixelCanvas.pointer().pixelCoordinate()
      
    # Due to animation, the evaluation paper is fully displayed a second after it's activated.
    @displayed = new ReactiveField false
    
    @autorun (computation) =>
      active = @active()
      
      if active
        @_displayedTimeout = Meteor.setTimeout =>
          @displayed true
        ,
          1000
        
      else
        Meteor.clearTimeout @_displayedTimeout
        @displayed false
        
    @pixelArtEvaluationProperty = new ComputedField =>
      @bitmap()?.properties?.pixelArtEvaluation
    
    @enabledCriteria = new ComputedField =>
      return [] unless pixelArtEvaluationProperty = @pixelArtEvaluationProperty()
      
      criterion for criterion of PAG.Criteria when pixelArtEvaluationProperty[_.lowerFirst criterion]
      
    @engineComponent = new PAG.EngineComponent
      pixelArtEvaluation: => @pixelArtEvaluation()
      displayedCriteria: =>
        return [] unless @displayed()
        
        if activeCriterion = @activeCriterion()
          [activeCriterion]
        
        else
          @enabledCriteria()
        
      filterToCategoryValue: => if @displayed() then @hoveredCategoryValue() else null
      focusedPixel: => if @displayed() then @hoveredPixel() else null
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Force the analyze tool when activated.
    @autorun (computation) =>
      return unless @active()
      
      analyzeTool = @interface.getOperator PAA.PixelPad.Apps.Drawing.Editor.Tools.Analyze
      
      # We need to compare to the active tool ID since the active tool field won't have time to recompute yet.
      return if @interface.activeTool() is analyzeTool
      
      # Activate the analyze tool, storing the previous one.
      Tracker.nonreactive =>
        # Note: We don't want to reactively read the stored tool
        # since it will be updated before the active tool recomputes.
        return if @interface.storedTool() is analyzeTool

        @interface.activateTool analyzeTool, true
  
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      return if @desktop.focusedMode()
      
      @deactivate()
      
      # Deactivate the analyze tool to restore the previous one.
      Tracker.nonreactive => @interface.deactivateTool()
      
    # Update evaluation where requested.
    @autorun (computation) =>
      return unless pixelArtEvaluationProperty = @pixelArtEvaluationProperty()
      return unless pixelArtEvaluation = @pixelArtEvaluation()
      evaluation = pixelArtEvaluation.evaluate pixelArtEvaluationProperty
      
      Tracker.nonreactive =>
        # Only update evaluation when we're at the end of history to prevent recalculation when undoing/redoing
        # (in case we change evaluation and this would cause new values—history is more important).
        asset = @interface.getLoaderForActiveFile()?.asset()
        return unless asset.historyPosition is asset.history.length

        # See if there was any change from the current data.
        return if _.objectContains asset.properties.pixelArtEvaluation, evaluation
        
        pixelArtEvaluationProperty = _.extend {}, asset.properties.pixelArtEvaluation, evaluation
      
        updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), asset, 'pixelArtEvaluation', pixelArtEvaluationProperty
        asset.executeAction updatePropertyAction, true
    
  onRendered: ->
    super arguments...
    
    @content$ = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @contentHeight @content$.outerHeight()
    
    @_resizeObserver.observe @content$[0]
    
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
    @_pixelArtEvaluation?.destroy()
    
  onBackButton: ->
    return unless @activeCriterion()
    
    @setCriterion null
    
    # Inform that we've handled the back button.
    true
    
  editorDrawComponents: -> [
    @engineComponent
  ]
  
  activate: (criterion = null) ->
    @_changeActive true
    @activeCriterion criterion
    @audio.open()
    
  deactivate: ->
    @_changeActive false
    @audio.close()
    
  # Use this to change the criterion when already active.
  setCriterion: (criterion) ->
    @activeCriterion criterion
    @audio.flipPaper()
    
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
      'click .paper': @onClickPaper
      'pointerenter .paper': @onPointerEnterPaper
      'pointerleave .paper': @onPointerLeavePaper
    
  onClickPaper: (event) ->
    return if @active()

    @activate()
  
  onPointerEnterPaper: (event) ->
    return if @active()
    
    @audio.lift()
    @_liftTime = Date.now()
    
  onPointerLeavePaper: (event) ->
    return if @active()
    
    @audio.release() if Date.now() - @_liftTime > 100
  
  class @CriterionEnabled extends AM.DataInputComponent
    @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.CriterionEnabled'
    @register @id()
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox
      
    onCreated: ->
      super arguments...
      
      @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    load: ->
      criterion = @data()
      
      _.nestedProperty @pixelArtEvaluation.pixelArtEvaluationProperty(), criterion.propertyPath
    
    save: (value) ->
      criterion = @data()
      
      pixelArtEvaluationProperty = EJSON.clone @pixelArtEvaluation.pixelArtEvaluationProperty()
      
      if value
        # Enable all subcriteria if they exist.
        criterionData = {}
        
        if PAG.Subcriteria[criterion.id]
          for subcriterion of PAG.Subcriteria[criterion.id]
            criterionData[_.lowerFirst subcriterion] = {}
        
        _.nestedProperty pixelArtEvaluationProperty, criterion.propertyPath, criterionData
        
      else
        _.deleteNestedProperty pixelArtEvaluationProperty, criterion.propertyPath
        
        # If this is a subcriteria, check that the parent even has any subcriteria left.
        if criterion.parentId
          found = false
          criterionProperty = _.lowerFirst criterion.parentId

          for subcriterion of PAG.Subcriteria[criterion.parentId]
            found = true if pixelArtEvaluationProperty[criterionProperty][_.lowerFirst subcriterion]
            
          unless found
            # No subcriteria are left, we can disable the whole criteria.
            delete pixelArtEvaluationProperty[criterionProperty]
            
      asset = @pixelArtEvaluation.interface.getLoaderForActiveFile()?.asset()
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), asset, 'pixelArtEvaluation', pixelArtEvaluationProperty
      
      asset.executeAction updatePropertyAction
      
      if value
        @pixelArtEvaluation.audio.checkmarkOn()
        
      else
        @pixelArtEvaluation.audio.checkmarkOff()