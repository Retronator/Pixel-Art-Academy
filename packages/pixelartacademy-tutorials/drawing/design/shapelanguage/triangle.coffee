AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Triangle extends PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapesAsset
  @displayName: -> "Triangle"

  @description: -> """
    A versatile shape that ranges from dynamic to dangerous.
  """

  @fixedDimensions: -> width: 65, height: 31
  @backgroundColor: -> new THREE.Color '#febe96'
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 156 / 255, g: 66 / 255, b: 132 / 255]
      ]
  
  @initialize()

  Asset = @

  class @Up extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Up"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      An upright triangle feels balanced and divine.
    """
    
    @initialize()
  
  class @Right extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Right"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      A sideways triangle has direction that can convey movement or action.
    """
    
    @initialize()
  
  class @Down extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Down"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      An inverted triangle feels powerful, but also unpredictable.
    """
    
    @initialize()
