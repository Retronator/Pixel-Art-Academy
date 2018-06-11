AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.Pico8.Game extends AM.Document
  @id: -> 'PixelArtAcademy.Pico8.Game'
  # slug: unique identifier used in URLs to access this game
  # artwork: Pixel Art Database entry representing this game
  #   _id
  # cart: information related to the game executable
  #   url: location of a cartridge
  @Meta
    name: @id()
    fields: =>
      artwork: @ReferenceField PADB.Artwork, [], false

  # Subscriptions

  @all: @subscription 'all'
