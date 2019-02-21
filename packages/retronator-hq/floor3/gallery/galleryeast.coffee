LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryEast extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.GalleryEast'
  @url: -> 'retronator/gallery/east'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Gallery east wing"
  @shortName: -> "gallery east"
  @description: ->
    "
      The east wing of the gallery opens up with an atrium that is shared with the art studio one floor above.
      More artworks line the walls, with tables in the middle holding interactive installations.
    "

  @illustration: ->
    name: 'retronator/hq/floor3/gallery/gallery'
    cameraAngle: 'East'
    height: 120

  @initialize()

  constructor: ->
    super arguments...

    # We create our own instance of the NPC. We don't want to just send a class to things either,
    # because our custom class uses the same ID and it would collide with the normal NPC instance.
    @corinne = new HQ.GalleryEast.Corinne

  destroy: ->
    super arguments...

    @corinne.destroy()

  things: -> [
    @corinne
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.GalleryWest
