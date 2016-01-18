AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Apps.Calendar extends AM.Component
  @register 'PixelArtAcademy.Apps.Calendar'

  onCreated: ->
    super

    # Enable translations.
    @initializeArtificialBabel PAA.babelServer

    # Create calendar providers.
    @providers = [
      new PAA.PixelDailies.ThemeCalendarProvider()
    ]
