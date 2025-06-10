AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Circle extends PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapesAsset
  @displayName: -> "Circle"

  @description: -> """
    A shape that evokes safety, connection, harmony, playfulness, and warmth.
  """

  @fixedDimensions: -> width: 72, height: 33
  @backgroundColor: -> new THREE.Color '#a6e2fe'
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 128 / 255, b: 136 / 255]
      ]
  
  @initialize()

  Asset = @

  class @Circle extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Circle"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      A circle has no sides, no up or down, no left or right. This can symbolize unity and wholeness.
    """
    
    @initialize()
  
  class @Ellipse extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Ellipse"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      Rounded shapes guide our eyes around them in an inviting manner.
    """
    
    @initialize()
  
  class @Blob extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Blob"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      Curved surfaces appear changeable and harmless.
    """
    
    @initialize()
