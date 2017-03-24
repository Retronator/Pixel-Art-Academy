LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Bookshelves extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store.Bookshelves'
  @url: -> 'retronator/store/bookshelves'

  @version: -> '0.0.1'

  @fullName: -> "Retronator Store bookshelves"
  @shortName: -> "bookshelves"
  @description: ->
    "
      At the top of the stairs, the floor opens onto a cafe-style co-working space/store hybrid that gives you that warm, 
      bookstore feeling. The place owner, Retro,
      is sitting behind a long desk that doubles as the store checkout area. Yellow walls and pixel art decals
      immediately brighten your day. You can see store shelves further out to the east.
    "

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.Store
