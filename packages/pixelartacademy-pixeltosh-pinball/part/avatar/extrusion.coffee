AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Extrusion extends Pinball.Part.Avatar.TriangleMesh
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    lines = []

    for core in @pixelArtEvaluation.layers[0].cores
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.x *= -1 if @properties.flipped
          point.y -= @bitmapOrigin.y
          
        lines.push points
    
    @geometryData = @constructor._createExtrudedVerticesAndIndices lines, 0, -@height

  yPosition: -> @height
