AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Shape
  @roughEdgeMargin: 0.001 # m
  
  @detectShape: (pixelArtEvaluation, properties) -> throw new AE.NotImplementedException "A part shape must create a shape instance if it can be detected."
  
  @_detectCircle: (pixelArtEvaluation) ->
    # We must have only one core and line.
    layer = pixelArtEvaluation.layers[0]
    return unless layer.cores.length is 1 and layer.lines.length is 1
    
    # See if points of the line form a circle.
    line = layer.lines[0]

    center = new THREE.Vector2
    center.add point for point in line.points
    center.multiplyScalar 1 / line.points.length
    
    distancesFromCenter = for point in line.points
      center.distanceTo point
      
    radius = _.sum(distancesFromCenter) / distancesFromCenter.length

    deviationsFromRadius = for distanceFromCenter in distancesFromCenter
      Math.abs distanceFromCenter - radius
      
    # We allow for a 1 pixel deviation from the radius.
    return if _.max(deviationsFromRadius) > 1

    center.x += 0.5
    center.y += 0.5
    radius += 0.5

    position: center
    radius: radius
  
  collisionShapeMargin: -> @constructor.roughEdgeMargin
  
  createPhysicsDebugGeometry: ->
    throw new AE.NotImplementedException "Part must provide a geometry for debugging physics."
  
  createCollisionShape: ->
    throw new AE.NotImplementedException "Part must provide a collision shape."
  
  yPosition: ->
    throw new AE.NotImplementedException "Part must specify at which y coordinate it should appear."
