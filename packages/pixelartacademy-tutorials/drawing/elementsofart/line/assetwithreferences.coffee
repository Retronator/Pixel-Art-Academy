AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @referenceNames: -> throw new AE.NotImplementedException "Asset with references must provide reference names."

  @svgUrl: -> null
  @goalChoices: ->
    for name in @referenceNames()
      referenceUrl: "/pixelartacademy/tutorials/drawing/elementsofart/line/#{name}.jpg"
      svgUrl: "/pixelartacademy/tutorials/drawing/elementsofart/line/#{name}.svg"
    
  @references: -> "/pixelartacademy/tutorials/drawing/elementsofart/line/#{name}.jpg" for name in @referenceNames()
  
  @breakPathsIntoSteps: -> false
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
