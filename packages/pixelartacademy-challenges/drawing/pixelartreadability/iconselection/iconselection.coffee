AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection"

  @displayName: -> "The Graphics Book of Icons"

  @description: -> """
    Successfully draw at least one 16×16 icon in the book to complete the challenge.
  """

  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @defaultUrl = 'the-graphics-book-of-icons'
  
  @initialize()
  
  @parts =
    transport: title: 'Transport'
    buildings: title: 'Buildings'
    toolsAndWeapons: title: 'Tools and Weapons'
    furniture: title: 'Furniture'
    musicalInstruments: title: 'Musical Instruments'
    householdItems: title: 'Household Items'
    
  @labels =
    transport: ['airplane', 'bicycle', 'car', 'helicopter', 'hot air balloon', 'pickup truck', 'sailboat']
    buildings: ['castle', 'church', 'skyscraper', 'windmill']
    toolsAndWeapons: ['axe', 'cannon', 'hammer', 'knife', 'rifle', 'saw', 'scissors', 'sword']
    furniture: ['bench', 'chair', 'couch', 'door', 'table']
    musicalInstruments: ['guitar', 'harp', 'piano', 'saxophone', 'trumpet', 'violin']
    householdItems: ['alarm clock', 'bottle', 'candle', 'cup', 'eyeglasses', 'fan', 'hat', 'hourglass', 'shoe', 'spoon', 'teapot', 'teddy bear', 'umbrella']
  
  constructor: ->
    super arguments...
    
    # Calculate contents.
    partNumber = 0
    iconNumber = 0
    pageNumber = 2
    
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
      
  destroy: ->
    @document.stop()
    
  urlParameter: ->
    # Try to return the current bitmap ID if it's one of our icons.
    return bitmapId if bitmapId = @_getBitmapId()
    
    # No icon has been selected, so return the default URL.
    @constructor.defaultUrl
    
  _getBitmapId: ->
    return unless parameter = AB.Router.getParameter 'parameter3'
    return unless icons = PAA.Challenges.Drawing.PixelArtReadability.state 'icons'
    
    for label, labelEntry of icons
      for size, icon of labelEntry.sizes
        return icon.bitmapId if icon.bitmapId is parameter
        
    null
  
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
