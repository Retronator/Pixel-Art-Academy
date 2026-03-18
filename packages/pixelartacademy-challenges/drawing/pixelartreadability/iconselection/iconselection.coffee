AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
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
    
  urlParameter: -> 'the-graphics-book-of-icons'
  
  width: -> 56
  height: -> 82
