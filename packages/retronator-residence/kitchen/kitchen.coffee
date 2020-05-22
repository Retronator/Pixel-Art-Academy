LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Kitchen extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Kitchen'
  @url: -> 'retronator/residence/kitchen'
  @region: -> HQ.Residence

  @version: -> '0.0.1'

  @fullName: -> "kitchen"
  @description: ->
    "
      You enter a spacious room with a kitchen island and a dinning table on the south end.
      The room continues north to the living room area.
      Wide suspended stairs connect upstairs and give the room a modern vibe.
    "
  
  @initialize()

  things: -> [
    @constructor.Watermelon.unlessCollected()
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Up}": HQ.Residence.UpstairsHallway
    "#{Vocabulary.Keys.Directions.Northwest}": HQ.Residence.UpstairsHallway
    "#{Vocabulary.Keys.Directions.West}": HQ.Residence.Hallway
    "#{Vocabulary.Keys.Directions.North}": HQ.Residence.LivingRoom
