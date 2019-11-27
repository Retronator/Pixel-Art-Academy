LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Items.AcceptanceLetter extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Items.AcceptanceLetter'
  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "acceptance letter"
  @shortName: -> "letter"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      Every time _char_ looks at _their_ acceptance letter to the Retropolis Academy of Art, it makes _them_ smile.
    "
    
  @initialize()
