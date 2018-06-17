AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.DevKit extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Pico8.DevKit'

  @fullName: -> "PICO-8 DevKit"

  @storeDescription: -> "
    One thing the PixelBoy app can't do is let you create games of your own. For that you will need to get the
    full PICO-8 experience by purchasing the development kit directly from Lexallofle. It includes tools for editing
    code, music, sound, sprites, and maps built right into the console.
  "
    
  @storeSeller: -> "Lexaloffle"
  @storeUrl: -> 'https://www.lexaloffle.com/pico-8.php'

  @initialize()
