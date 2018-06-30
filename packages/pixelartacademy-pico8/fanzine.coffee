AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Fanzine extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Pico8.Fanzine'

  @fullName: -> "PICO-8 Fanzine"

  @storeDescription: -> "
    Enter the marvelous world of PICO-8! PICO-8 Zine is a 48-page fanzine made by and for PICO-8 users.
    Learn how to make a game (from the code, sprite, music point of view) and discover the history of PICO-8.
  "

  @storeSeller: -> "Itch.io"
  @storeUrl: -> 'https://sectordub.itch.io/pico-8-fanzine-1'

  @initialize()
