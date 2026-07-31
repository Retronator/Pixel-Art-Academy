AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @volumeNumber: -> throw new AE.NotImplementedException 'Icon selection must specify which volume it is.'
  @coverIconsCounts: -> throw new AE.NotImplementedException 'Icon selection must specify how many icons it has on the cover.'

  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
    
  @getIconStatus: (bitmap) ->
    completed: bitmap.properties.readabilityAnalysis.passes
    started: bitmap.properties.readabilityAnalysis.regions[0].labels?
  
  constructor: ->
    super arguments...
    
    # Calculate contents.
    partNumber = 0
    iconNumber = 0
    pageNumber = 3
    
    @contents = _.cloneDeep @constructor.parts
    @pages = []
    
    for partId, part of @contents
      partNumber++
      part.number = partNumber
      
      # Increase the page number for the category page on the right page of the spread.
      pageNumber++ unless pageNumber % 2
      pageNumber++
      
      part.titlePageNumber = pageNumber
      
      @pages[pageNumber] = part
      
      # Create icon entries.
      part.iconEntries = for label in @constructor.labels[partId]
        iconNumber++
        pageNumber++
        iconEntry = {iconNumber, label, name: _.titleCase(label), pageNumber}

        @pages[pageNumber] = iconEntry

        iconEntry
    
    # Provide the bitmap data to the editor. We need to keep it
    # persistent even after the URL is changed to allow for transitions.
    @_lastBitmapId = null
    
    @document = new AE.LiveComputedField =>
      return unless bitmapId = @_getBitmapId() or @_lastBitmapId
      @_lastBitmapId = bitmapId
      LOI.Assets.Bitmap.getDocumentForId bitmapId
      
    @_updateIconStatusAutorun = Tracker.autorun (computation) =>
      # When an icon is being drawn, update its status in the state.
      return unless bitmap = @document()
      return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
      
      label = bitmap.properties.readabilityAnalysis.regions[0].targetLabel
      size = bitmap.bounds.width
      
      return unless iconData = icons[label]?.sizes[size]
      
      iconStatus = @constructor.getIconStatus bitmap
      
      # Started and completed are stored as true and undefined.
      startedCorrect = if iconStatus.started then iconData.started else not iconData.started?
      completedCorrect = if iconStatus.completed then iconData.completed else not iconData.completed?
      
      return if startedCorrect and completedCorrect
      
      unless startedCorrect
        if iconStatus.started
          iconData.started = true
          
        else
          delete iconData.started
          
      unless completedCorrect
        if iconStatus.completed
          iconData.completed = true
          
        else
          delete iconData.completed
      
      PAA.Challenges.Drawing.PixelArtReadability.state 'icons', icons
      
  destroy: ->
    @document.stop()
    @_updateIconStatusAutorun.stop()
    
  urlParameter: ->
    # Try to return the current bitmap ID if it's one of our icons.
    return bitmapId if bitmapId = @_getBitmapId()
    
    # No icon has been selected, so return the default URL.
    @constructor.defaultUrl()
    
  _getBitmapId: ->
    return unless parameter = AB.Router.getParameter 'parameter3'
    return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
    
    for label, labelEntry of icons when @_ownLabel label
      for size, icon of labelEntry.sizes
        return icon.bitmapId if icon.bitmapId is parameter
        
    null
    
  _ownLabel: (label) ->
    for category, labels of @constructor.labels
      return true if label in labels
      
    false
  
  completed: -> @_getIconStatusIfRevealedAnalysis 'completed'
  started: -> @_getIconStatusIfRevealedAnalysis 'started'
  
  _getIconStatusIfRevealedAnalysis: (property) ->
    return unless bitmap = @document()
    
    # We send an explicit false so that changing this to a truthy value will trigger the completed sound.
    return false unless bitmap.properties.readabilityAnalysis.revealed
    
    @constructor.getIconStatus(bitmap)[property] or false
  
  width: -> 56
  height: -> 82
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
    ]
  
  previewInfo: ->
    return unless bounds = @document()?.bounds
    
    scale = 128 / bounds.width
    borderWidth = 12
    
    left = "calc(50% - 76rem)"
    
    if AB.Router.getParameter('parameter4') is 'edit'
      top = "calc(50% - 76rem)"
      
    else
      # When the drawing is not being edited, move it above the top.
      top = "-152rem"
    
    position = {left, top}

    {borderWidth, scale, position}
