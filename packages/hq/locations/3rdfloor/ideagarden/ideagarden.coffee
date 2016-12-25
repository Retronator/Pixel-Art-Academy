LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.IdeaGarden extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.IdeaGarden'
  @url: -> 'retronator/ideagarden'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator Idea Garden"
  @shortName: -> "Idea Garden"
  @description: ->
    "
      In a small room that continues the green theme of the chillout space, tables are placed around the walls in a
      greenhouse fashion. Digital glass screens render plants at various stages of growth to indicate the progress of
      showcased projects. A glass door to the east continues into the studio space for Patron Club members.
    "
  
  @initialize()

  @initialState: ->
    things = {}
    things[HQ.Actors.ElevatorButton.id()] = displayOrder: 1

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Chillout.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Theater.id()

    _.merge {}, super,
      things: things
      exits: exits
  
  constructor: ->
    super
    
    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: '3b'

  onScriptsLoaded: ->
    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: '3b'
