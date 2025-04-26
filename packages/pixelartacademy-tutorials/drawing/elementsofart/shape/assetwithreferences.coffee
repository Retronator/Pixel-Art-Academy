AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @referenceNames: -> throw new AE.NotImplementedException "Asset with references must provide reference names."

  @svgUrl: -> null
  @goalChoices: ->
    for name in @referenceNames()
      referenceUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.jpg"
      svgUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.svg"
    
  @references: -> "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.jpg" for name in @referenceNames()
  
  @canvasExtensionDirection: -> @CanvasExtensionDirection.Vertical
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
