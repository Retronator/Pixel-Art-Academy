AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.Pico8.Game extends AM.Document
  @id: -> 'PixelArtAcademy.Pico8.Game'
  # slug: unique identifier used in URLs to access this game
  # artwork: Pixel Art Database entry representing this game
  #   _id
  # cartridge: information related to the game executable
  #   url: location of the cartridge
  # assets: array of assets used in the game
  #   id: id of the asset, matching the project asset id for replacement purposes
  #   x, y: top-left block position in the sprite sheet
  @Meta
    name: @id()
    fields: =>
      artwork: @ReferenceField PADB.Artwork, [], false

  # Subscriptions

  @all: @subscription 'all'
