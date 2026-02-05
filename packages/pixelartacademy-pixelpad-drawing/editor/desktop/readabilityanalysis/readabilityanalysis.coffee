AM = Artificial.Mirage
AMu = Artificial.Mummification
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

RA = PAA.Practice.ReadabilityAnalysis

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis'
  @register @id()
  
  @sheetTopSliceHeight = 42
  @sheetRepeatingSliceHeight = 16
  
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
    
  constructor: ->
    super arguments...

    @active = new ReactiveField false
    @_wasActive = false
    
  onCreated: ->
    super arguments...
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @contentHeight = new ReactiveField 0
    
    @bitmap = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()
    
    @bitmapObject = new ComputedField =>
      @bitmap()
    ,
      (a, b) => a is b
    
    @readabilityAnalysis = new ComputedField =>
      return unless bitmap = @bitmapObject()
      @_readabilityAnalysis?.destroy()
      @_readabilityAnalysis = new RA bitmap
      
    # Due to animation, the analysis paper is fully displayed a second after it's activated.
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
        
    @readabilityAnalysisProperty = new ComputedField =>
      @bitmap()?.properties?.readabilityAnalysis
          
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      return if @desktop.focusedMode()
      
      @deactivate()
      
      # Deactivate the analyze tool to restore the previous one.
      Tracker.nonreactive => @interface.deactivateTool()
      
    # Update analysis where requested.
    @autorun (computation) =>
      return unless @readabilityAnalysisProperty()
      return unless readabilityAnalysis = @readabilityAnalysis()
      
      Tracker.nonreactive =>
        # Only update analysis when we're at the end of history to prevent recalculation when undoing/redoing
        # (in case we change analysis and this would cause new values—history is more important).
        asset = @interface.getLoaderForActiveFile()?.asset()
        historyLength = asset.history?.length or AMu.Document.Versioning.ActionArchive.getHistoryLengthForDocument asset._id
        return unless asset.historyPosition is historyLength

        # See if there was any change from the current data.
        readabilityAnalysisProperty = {}
        
        for classifier in ['symbolic', 'realistic']
          readabilityAnalysisProperty[classifier] = []
          
          probableLabels = _.filter readabilityAnalysis.labels[classifier], (labelProbability) => labelProbability.probability > 0.01
          probableLabels.sort (a, b) => a.probability - b.probability
          
          for probableLabel in probableLabels
            readabilityAnalysisProperty.classifier.push
              label: probableLabel.label
              probabilityPercentage: Math.round probableLabel.probability * 100
        
        return if EJSON.equals asset.properties.readabilityAnalysis,readabilityAnalysisProperty
        
        updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), asset, 'readabilityAnalysis', readabilityAnalysisProperty
        asset.executeAction updatePropertyAction, true
    
  onRendered: ->
    super arguments...
    
    @autorun (computation) =>
      @_resizeObserver?.disconnect()
      return unless @paperDisplayed()

      await _.waitForFlush()
    
      @$content = @$('.content')
      @_resizeObserver = new ResizeObserver =>
        @contentHeight @$content.outerHeight() / LOI.adventure.interface.display.scale()
      
      @_resizeObserver.observe @$content[0]
    
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
    @_readabilityAnalysis?.destroy()
  
  activate: ->
    @_changeActive true
    
  deactivate: ->
    @_changeActive false

  _changeActive: (value) ->
    @active value
    
    return if value is @_wasActive
    @_wasActive = value
    
    return unless @isRendered()
    
    if value
      @audio.open()
    
    else
      @audio.close()
    
    Tracker.nonreactive =>
      editor = @interface.getEditorForActiveFile()

      camera = editor.camera()
      scale = camera.effectiveScale()
      
      paperHeight = @$('.paper').height() / scale
      originDeltaY = paperHeight / 2
      originDeltaY *= -1 unless value
      
      originDataField = camera.originData()
      origin = originDataField.value()
      
      camera.translateTo
        x: origin.x
        y: origin.y + originDeltaY
      ,
        1

  activeClass: ->
    'active' if @active()
    
  paperDisplayed: ->
    # Display the paper if the property is defined and we're not explicitly told to not display it.
    @readabilityAnalysisProperty()
  
  paperSheetStyle: ->
    minimumHeight = @contentHeight()
    
    # Paper sheet has to be a multiple of repeating slice heights plus an additional slice
    # (since borders are centered) for the repeating pattern to be aligned correct.
    repeatingSlicesCount = Math.ceil (minimumHeight - @constructor.sheetTopSliceHeight - @constructor.sheetRepeatingSliceHeight) / (2 * @constructor.sheetRepeatingSliceHeight)
    
    height: "#{@constructor.sheetTopSliceHeight + (1 + 2 * repeatingSlicesCount) * @constructor.sheetRepeatingSliceHeight}rem"
  
  contentPlaceholderStyle: ->
    height: "#{@contentHeight()}rem"
    
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
