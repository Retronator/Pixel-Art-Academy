LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Locations.Play extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.LearnMode.Locations.Play'
  @url: -> 'play'
  @region: -> PAA.LearnMode.Region
  
  @version: -> '0.0.1'

  @fullName: -> "play"
  
  @initialize()
