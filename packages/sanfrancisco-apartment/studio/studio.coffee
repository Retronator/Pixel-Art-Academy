LOI = LandsOfIllusions
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Apartment.Studio extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Apartment.Studio'
  @url: -> 'sf/apartment/studio'
  @region: -> Apartment
  @isPrivate: -> true

  @version: -> '0.0.1'

  @fullName: -> "studio apartment"
  @shortName: -> "studio"
  @description: ->
    "
      You are in _char's_ studio apartment in San Francisco. It's not much, and the rent is insanely high, but that's
      the price you pay to be in the tech capital of the world.
    "
  
  @initialize()

  onCreated: ->
    super arguments...

    @emailNotification = new @constructor.EmailNotification
    
  onDestroyed: ->
    super arguments...

    @emailNotification.destroy()

  things: -> [
    @constructor.Computer
    @constructor.Bed
    @constructor.KitchenCabinet.withItems()...
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": Apartment.Hallway
