LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.LivingRoom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.LivingRoom'
  @url: -> 'retronator/residence/livingroom'
  @region: -> HQ.Residence

  @version: -> '0.0.1'

  @fullName: -> "living room"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    # Reference to The Sims 2.
    "
      A TV with every possible gaming console plugged into it, old and new, is the main attraction of the living room.
      You also see a chess table and a guitar, probably for gaining logic and creativity skill levels.
    "
  
  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": HQ.Residence.Kitchen
