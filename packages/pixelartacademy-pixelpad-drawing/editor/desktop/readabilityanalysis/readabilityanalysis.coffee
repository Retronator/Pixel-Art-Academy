AE = Artificial.Everywhere
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
  
  @debug = false
  
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
    
    @debug = @constructor.debug

    @active = new ReactiveField false
    @_wasActive = false
    
    @revealed = new ReactiveField false
    
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
    
    @asset = new ComputedField =>
      @interface.parent.activeAsset()
    ,
      (a, b) => a is b
    
    @readabilityAnalysis = new ComputedField =>
      @_readabilityAnalysis?.destroy()
      return unless asset = @asset()
      
      # Try to reuse the readability analysis instance from the asset.
      if asset.initialized
        return unless asset.initialized()
        
        if asset.readabilityAnalysisInstance
          @_readabilityAnalysis = null
          return asset.readabilityAnalysisInstance()
      
      return unless bitmap = @bitmapObject()
      @_readabilityAnalysis = Tracker.nonreactive => new RA bitmap
    
    @hoveredPixel = new ComputedField =>
      pixelCanvas = @interface.getEditorForActiveFile()
      pixelCanvas.pointer().pixelCoordinate()
      
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
      
    @engineComponent = new RA.EngineComponent
      readabilityAnalysis: =>
        return unless readabilityAnalysis = @readabilityAnalysis()
        readabilityAnalysis.depend()
        readabilityAnalysis
      
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
    @readabilityAnalysisPropertyExists = new ComputedField =>
      @readabilityAnalysisProperty()?
      
    @recognition = new ReactiveField null
    
    @autorun (computation) =>
      return unless @readabilityAnalysisPropertyExists()
      return unless readabilityAnalysis = @readabilityAnalysis()
      readabilityAnalysis.depend()
      return unless readabilityAnalysis.regions
      
      Tracker.nonreactive =>
        # Generate a report with probability percentages of 1% or more.
        readabilityAnalysisProperty = {}
        recognition = null
        
        if readabilityAnalysis.regions.length
          readabilityAnalysisProperty.regions = []
        
          for region, regionIndex in readabilityAnalysis.regions
            regionAnalysis = _.pick region, 'targetLabel', 'bounds'
            
            readabilityAnalysisProperty.regions[regionIndex] = regionAnalysis
          
            if region.labels
              regionAnalysis.labels = {}
              
              for classifierName, labelProbabilities of region.labels
                propertyLabelProbabilities = []
                regionAnalysis.labels[classifierName] = propertyLabelProbabilities
                
                for labelProbability in labelProbabilities when labelProbability.probability >= 0.01
                  propertyLabelProbabilities.push
                    label: labelProbability.label
                    probabilityPercentage: Math.round labelProbability.probability * 100
                  
          # Run the analysis criteria.
          recognition = []
          
          for region, regionIndex in readabilityAnalysisProperty.regions
            regionRecognition = @_regionRecognitionResult region, region.bounds or readabilityAnalysis.bitmap.bounds
            recognition.push regionRecognition
            region.recognition = passes: regionRecognition.passes if regionRecognition
            
            # See if all criteria pass. If any of them are not set, we can't pass or fail yet.
            criteriaPasses = [region.recognition?.passes]
            region.passes = _.every criteriaPasses if _.every criteriaPasses, (criterionPasses) => criterionPasses?
          
          # See if all regions pass. If any of them are not set, we can't pass or fail yet.
          if _.every readabilityAnalysisProperty.regions, (region) => region.passes?
            readabilityAnalysisProperty.passes = _.every readabilityAnalysisProperty.regions, (region) => region.passes
          
        # Store analysis responses for output.
        @recognition recognition
        
        # See if there was any change from the current data.
        asset = @interface.getLoaderForActiveFile()?.asset()
        return if EJSON.equals asset.properties.readabilityAnalysis, readabilityAnalysisProperty
        
        # Only update analysis when we're at the end of history to prevent recalculation when undoing/redoing
        # (in case we change analysis and this would cause new values—history is more important).
        historyLength = asset.history?.length or AMu.Document.Versioning.ActionArchive.getHistoryLengthForDocument asset._id
        return unless asset.historyPosition is historyLength
        
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
    
    @readabilityAnalysis.stop()
  
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
    
    if value
      @audio.open()
      Meteor.setTimeout =>
        @revealed true
      ,
        1000
    
    else
      @audio.close()
      @revealed false
    
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
  
  revealedClass: ->
    'revealed' if @revealed()
    
  paperDisplayed: ->
    # Display the paper if the property is defined.
    @readabilityAnalysisProperty()
  
  contentPlaceholderStyle: ->
    height: "#{@contentHeight()}rem"
    
  pixeltoshClass: ->
    return unless readabilityAnalysisProperty = @readabilityAnalysisProperty()
    return unless readabilityAnalysisProperty.passes?
    
    if readabilityAnalysisProperty.passes then 'passes' else 'fails'
  
  regions: ->
    return unless regions = @readabilityAnalysisProperty()?.regions
    return unless recognition = @recognition()
    
    for region, regionIndex in regions
      _.extend {}, region,
        index: regionIndex
        number: regionIndex + 1
        label: region.targetLabel
        recognition: recognition[regionIndex]
        classifierResults: ({classifierName, labelProbabilities: labelProbabilities[...5]} for classifierName, labelProbabilities of region.labels)
  
  liveClassifierResults: ->
    region = @currentData()
    regionIndex = region.index
    
    return unless readabilityAnalysis = @readabilityAnalysis()
    readabilityAnalysis.depend()
    return unless regions = readabilityAnalysis.regions
    
    region = regions[regionIndex]
    
    hoveredPixel = if @displayed() then @hoveredPixel() else null
    hoveredLines = if hoveredPixel then readabilityAnalysis.pixelArtEvaluation.getLinesAt hoveredPixel.x, hoveredPixel.y else []
    hoveredPoints = if hoveredPixel then readabilityAnalysis.pixelArtEvaluation.getPointsAt hoveredPixel.x, hoveredPixel.y else []
    hoveredElements = [hoveredLines..., hoveredPoints...]
    
    if hoveredElements.length
      strokeAnalysis = _.find regions[regionIndex].strokes, (strokeAnalysis) => strokeAnalysis.element is hoveredElements[0]
      labels = strokeAnalysis?.labels
      
    labels ?= region.labels
    
    for classifierName, labelProbabilities of labels
      labelProbabilityPercentages = for labelProbability in labelProbabilities when labelProbability.probability >= 0.01
        label: labelProbability.label
        probabilityPercentage: Math.round labelProbability.probability * 100
      
      {classifierName, labelProbabilities: labelProbabilityPercentages[...5]}
  
  resultPassesClass: (result) ->
    'passes' if result?.passes
  
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
