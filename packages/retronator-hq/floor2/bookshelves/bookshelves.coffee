LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Bookshelves extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store.Bookshelves'
  @url: -> 'retronator/store/bookshelves'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Store bookshelves"
  @shortName: -> "bookshelves"
  @description: ->
    "
      In the east, the store opens towards the building's glass front facade.
      Tall bookshelves line the walls, divided into sections.
    "

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.Store
