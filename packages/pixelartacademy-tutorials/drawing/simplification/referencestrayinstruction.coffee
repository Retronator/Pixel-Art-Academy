AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Simplification.ReferencesTrayInstruction"
  
  @assetClass: -> PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @firstAssetClass: -> PAA.Tutorials.Drawing.Simplification.Silhouette
  
  @message: -> """
    Open the references tray and choose an object to draw.
  """

  @initialize()
