AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Circle2 extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Circle 2"

  @description: -> """
    The circle shape language is often used to design protagonists and other friendly or cute characters.
  """

  @fixedDimensions: -> width: 29, height: 32
  
  @referenceNames: -> [
    'dragonwarrior'
    'kirbysdreamland2'
    'supermariobros2'
  ]
  
  @initialize()

  Asset = @
