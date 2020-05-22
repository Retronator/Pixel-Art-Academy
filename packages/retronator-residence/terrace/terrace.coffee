LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Terrace extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Terrace'
  @url: -> 'retronator/residence/terrace'
  @region: -> HQ.Residence

  @version: -> '0.0.1'

  @fullName: -> "terrace"
  @description: ->
    "
      A magnificent view of the SOMA district of San Francisco opens before you.
      The green roof of the Transbay Transit Center across the street immediately catches your attention,
      just before your eyes gaze upwards to the many downtown skyscrapers.
    "
  
  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.Residence.UpstairsHallway
