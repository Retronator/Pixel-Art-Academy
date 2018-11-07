LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Horizon
  constructor: (@options) ->

  drawToContext: (context) ->
    return unless currentNormal = @options.currentNormal()
    return unless cameraAngle = @options.cameraAngle()
    
    horizon = cameraAngle.getHorizon currentNormal

    context.strokeStyle = "#689cc0"
    context.lineWidth = 0.2
    context.beginPath()

    context.moveTo horizon.origin.x - horizon.direction.x * 1000 + 0.5, horizon.origin.y - horizon.direction.y * 1000 + 0.5
    context.lineTo horizon.origin.x + horizon.direction.x * 1000 + 0.5, horizon.origin.y + horizon.direction.y * 1000 + 0.5

    context.stroke()
