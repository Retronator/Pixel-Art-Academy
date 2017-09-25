LOI = LandsOfIllusions
PAA = PixelArtAcademy
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary
Verbs = Vocabulary.Keys.Verbs

class RS.AirportTerminal.BaggageClaim.BaggageCarousel extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terrace.BaggageCarousel'
  @fullName: -> "baggage carousel"
  @shortName: -> "carousel"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It's working tirelessly to deliver suitcases to airplane passengers.
    "

  @initialize()
