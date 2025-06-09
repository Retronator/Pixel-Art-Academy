AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Square2 extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Square 2"

  @description: -> """
    The square shape language can be used to design strong or serious characters.
  """

  @fixedDimensions: -> width: 26, height: 28
  
  @referenceNames: -> [
    'thelegendofzeldalinksawakeningdx'
  ]
  
  @initialize()

  Asset = @

  class @Zelda extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Zelda"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'thelegendofzeldalinksawakeningdx'
    
    @message: -> """
      Darknuts from The Legend of Zelda series are knights in heavy armor.
      The square appearance reinforces them as formidable, mid-game opponents.
    """
    
    @initialize()
