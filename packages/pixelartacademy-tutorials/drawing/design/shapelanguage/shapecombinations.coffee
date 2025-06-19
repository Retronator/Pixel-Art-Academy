AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

CartridgeTypes = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.SceneObject.Cartridge.Types

class PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapeCombinations extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Shape combinations"

  @description: -> """
    Characters are often designed using different shapes,
    to signal their multidimensional personality or simply to achieve other aesthetic or functional goals.
  """

  @fixedDimensions: -> width: 38, height: 45
  @backgroundColor: -> new THREE.Color '#fee28e'
  
  @referenceNames: -> [
    'sonicthehedgehog'
    'metalslug1stmission'
    'megaman2'
  ]
  
  @bitmapInfoTextsForReferences: -> [
    "Sonic the Hedgehog (1991, SEGA)"
    "Metal Slug 1st Mission (Ukiyotei, 1999)"
    "Mega Man 2 (Capcom, 1988)"
  ]
  
  @cartridgeTypesForReferences: -> [
    CartridgeTypes.Genesis
    CartridgeTypes.NeoGeoPocket
    CartridgeTypes.NES
  ]
  
  @rampsCountForReferences: -> [
    4,
    1,
    1
  ]
  
  @initialize()

  Asset = @

  class @Sonic extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Sonic"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'sonicthehedgehog'
    
    @message: -> """
      Sonic's silhouette is a perfect combination of cartoony circles with aerodynamic triangles.
      His large, triangular feet further underscore his focus on speed.
    """
    
    @initialize()

  class @MetalSlug extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.MetalSlug"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'metalslug1stmission'
    
    @message: -> """
      The titular Metal Slug super vehicle is far from a slow, indestructible tank.
      With its nimbleness and even the ability to jump, its shape lends better to a triangle than a rectangle.
      Yet, the overall triangle shape is composed of multiple circles, matching the comical, light-hearted art style of the series.
    """
    
    @initialize()

  class @MegaMan extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.MegaMan"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'megaman2'
    
    @message: -> """
      Mega Man 2's Wood Man is, like a tree trunk, both a square and a circle, depending on perspective.
      His wooden armor is sturdy and resilient, yet vulnerable to fire and blades.
      This form visually matches his unrelenting stance to protect nature.
    """
    
    @initialize()
