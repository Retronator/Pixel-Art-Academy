AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection.Volume1 extends PAA.Challenges.Drawing.PixelArtReadability.IconSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection.Volume1"
  
  @displayName: -> "The Graphics Book of Icons"

  @description: -> """
    Draw icons of various sizes to practice drawing pixel art with limited space.
  """
  
  @volumeNumber: -> 1
  
  @defaultUrl: -> 'the-graphics-book-of-icons'

  @coverIconsCounts: -> 8: 5, 16: 9, 32: 2
  
  @initialize()
  
  @parts =
    transport: title: 'Transport'
    buildings: title: 'Buildings'
    toolsAndWeapons: title: 'Tools and Weapons'
    furniture: title: 'Furniture'
    musicalInstruments: title: 'Musical Instruments'
    householdItems: title: 'Household Items'
    food: title: 'Food'
    
  @labels =
    transport: ['airplane', 'bicycle', 'car', 'helicopter', 'hot air balloon', 'pickup truck', 'sailboat']
    buildings: ['castle', 'church', 'skyscraper', 'windmill']
    toolsAndWeapons: ['axe', 'cannon', 'hammer', 'knife', 'rifle', 'saw', 'scissors', 'sword']
    furniture: ['bench', 'chair', 'couch', 'door', 'table']
    musicalInstruments: ['guitar', 'harp', 'piano', 'saxophone', 'trumpet', 'violin']
    householdItems: ['alarm clock', 'bottle', 'candle', 'cup', 'eyeglasses', 'fan', 'hat', 'hourglass', 'shoe', 'spoon', 'teapot', 'teddy bear', 'umbrella']
    food: ['bread', 'hamburger', 'pizza']
