LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Horizon
  constructor: (@meshCanvas) ->

  drawToContext: (context) ->
    return unless @meshCanvas.horizonEnabled()
    return unless currentNormal = @meshCanvas.currentNormal()
    return unless cameraAngle = @meshCanvas.cameraAngle()
    
    horizon = cameraAngle.getHorizon currentNormal

    context.strokeStyle = "#689cc0"
    context.lineWidth = 0.2
    context.beginPath()

    context.moveTo horizon.origin.x - horizon.direction.x * 1000 + 0.5, horizon.origin.y - horizon.direction.y * 1000 + 0.5
    context.lineTo horizon.origin.x + horizon.direction.x * 1000 + 0.5, horizon.origin.y + horizon.direction.y * 1000 + 0.5

    context.stroke()
