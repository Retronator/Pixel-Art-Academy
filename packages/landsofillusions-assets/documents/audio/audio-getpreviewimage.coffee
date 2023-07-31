AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

{cubicBezier} = require 'bresenham-zingl'

LOI.Assets.Audio::getPreviewImage = ->
  return new AM.Canvas unless @nodes?.length
  
  # Figure out how big the canvas needs to be to incorporate all
  bounds = null

  nodeSize = 10
  scale = 0.15

  for node in @nodes
    nodeBounds = new AE.Rectangle node.position.x * scale, node.position.y * scale, nodeSize, nodeSize

    if bounds
      bounds.union nodeBounds

    else
      bounds = nodeBounds

  bounds = bounds.toObject()
  bounds.width++
  bounds.height++

  canvas = new AM.ReadableCanvas bounds.width, bounds.height

  # Draw connections to canvas.
  canvas.context.strokeStyle = '#929292'

  imageData = canvas.getFullImageData()

  for node in @nodes when node.connections
    start =
      x: node.position.x + nodeSize / scale * 0.5 - bounds.x / scale
      y: node.position.y + nodeSize / scale - bounds.y / scale

    for connection in node.connections
      otherNode = _.find @nodes, (node) => node.id is connection.nodeId
      nodeClass = LOI.Assets.Engine.Audio.Node.getClassForType otherNode.type
      sideEntry = _.find nodeClass.parameters(), (parameter) => parameter.name is connection.input

      end =
        x: otherNode.position.x - bounds.x / scale
        y: otherNode.position.y - bounds.y / scale

      if sideEntry
        end.y += nodeSize / scale * 0.5

      else
        end.x += nodeSize / scale * 0.5

      bezierPoints = LOI.Assets.AudioEditor.AudioCanvas.Flowchart.createBezierPoints {start, end, sideEntry}

      bezierParameters = _.flatten _.map bezierPoints, (point) =>
        [Math.floor(point.x * scale), Math.floor(point.y * scale)]

      cubicBezier bezierParameters..., (x, y) =>
        return unless 0 <= x < imageData.width and 0 <= y < imageData.height

        pixelIndex = (x + y * imageData.width) * 4

        for value, offset in [146, 146, 146, 255]
          imageData.data[pixelIndex + offset] = value

  canvas.putFullImageData imageData

  # Draw nodes to canvas.
  canvas.context.fillStyle = '#000'

  for node in @nodes
    x = Math.floor(node.position.x * scale - bounds.x) + 0.5
    y = Math.floor(node.position.y * scale - bounds.y) + 0.5
    canvas.context.fillRect x, y, nodeSize, nodeSize
    canvas.context.strokeRect x, y, nodeSize, nodeSize

  canvas
