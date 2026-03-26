AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Square extends PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapesAsset
  @displayName: -> "Square"

  @description: -> """
    A shape that seems strong, stable, and serious.
  """

  @fixedDimensions: -> width: 73, height: 33
  @backgroundColor: -> new THREE.Color '#6c6c6c'
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 248 / 255, g: 246 / 255, b: 248 / 255]
      ]
  
  @initialize()

  Asset = @

  class @Square extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Square"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      A square is a reliable building block that can withstand pressure.
    """
    
    @initialize()
  
  class @Horizontal extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Horizontal"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      Rectangles can give us shelter or act as functional surfaces, communicating trust or seriousness.
    """
    
    @initialize()
  
  class @Vertical extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Vertical"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      When they are towering, they appear mighty, immovable, or inflexible.
    """
    
    @initialize()
