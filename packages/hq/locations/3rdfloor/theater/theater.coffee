LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Theater extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Theater'
  @url: -> 'retronator/theater'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Patron Club theater"
  @shortName: -> "theater"
  @description: ->
    "
      You are in a spacious theater constructed on the wide stairs that raise from third to fourth floor. 
      The south wall is a smooth white and doubles as the projection surface while you can see to the street through the
      east windows. You can see the painting studio up top to the north.
    "
  
  @initialize()

  constructor: ->
    super

  @initialState: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.IdeaGarden.id()
    exits[Vocabulary.Keys.Directions.Up] = HQ.Locations.Studio.id()
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Studio.id()

    _.merge {}, super,
      things: things
      exits: exits
