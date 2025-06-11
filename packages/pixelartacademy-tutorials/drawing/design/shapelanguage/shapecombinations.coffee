AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapeCombinations extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Shape combinations"

  @description: -> """
    Characters are often designed using different shapes,
    signaling their multidimensional personality or simply to achieve other aesthetic or functional goals.
  """

  @fixedDimensions: -> width: 38, height: 45
  @backgroundColor: -> new THREE.Color '#fee28e'
  
  @referenceNames: -> [
    'sonicthehedgehog'
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
