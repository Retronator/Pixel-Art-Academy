AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @referenceNames: -> throw new AE.NotImplementedException "Asset with references must provide reference names."

  @svgUrl: -> null
  @referenceSvgUrls: -> "/pixelartacademy/tutorials/drawing/elementsofart/line/#{name}.svg" for name in @referenceNames()
  @references: -> "/pixelartacademy/tutorials/drawing/elementsofart/line/#{name}.jpg" for name in @referenceNames()
  
  @progressivePathCompletion: -> false
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
