LOI = LandsOfIllusions

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class LOI.Construct.Locations.C3.Entrance extends LOI.Construct.Location
  @id: -> 'LandsOfIllusions.Construct.Locations.C3.Entrance'
  @url: -> 'c3/entrance'
  @scriptUrls: -> super.concat [
  ]
    
  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center entrance"
  @shortName: -> "entrance"
  @description: ->
    "
      You are in a hallway with big glass sliding doors to the north.
      The title Character Construction Center is printed across them.
      A little above, C3 is written in big letters in a way that resembles brain hemispheres.
    "
  
  @initialize()

  constructor: ->
    super

  @initialState: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = LOI.Construct.Locations.C3.Lobby.id()
    exits[Vocabulary.Keys.Directions.In] = LOI.Construct.Locations.C3.Lobby.id()

    _.merge {}, super,
      things: things
      exits: exits
