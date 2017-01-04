LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Chillout extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Chillout'
  @url: -> 'retronator/chillout'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions and Idea Garden entrance"
  @shortName: -> "chillout"
  @description: ->
    "
      At the top of the stairs is a cosy chillout area with bean bags placed on the sides. 
      There is a pond-like fountain in the middle of the floor, surrounded with stones and lush tropical greenery.
      The pond flows over the edge into a waterfall that reaches all the way down to the first floor.
      The hallway continues to the west and glass doors with a keycard reader lead south.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Down] = HQ.Locations.Store.id()
    exits[Vocabulary.Keys.Directions.Southeast] = HQ.Locations.Store.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.LandsOfIllusions.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.IdeaGarden.id()

    _.merge {}, super,
      things: things
      exits: exits
