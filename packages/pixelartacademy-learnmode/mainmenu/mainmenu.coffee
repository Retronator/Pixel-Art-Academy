LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.LearnMode.MainMenu extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.LearnMode.MainMenu'
  @url: -> ''
  @region: -> PAA.LearnMode.Region

  @version: -> '0.0.1'

  @fullName: -> "Main Menu"
  
  @initialize()
  
  isLandingPage: -> true
