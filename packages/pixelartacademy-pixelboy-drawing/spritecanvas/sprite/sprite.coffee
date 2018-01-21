LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Sprite
  constructor: (@spriteCanvas) ->

    @canvas = new ReactiveField null

    Tracker.autorun =>
      data = @spriteCanvas.drawing.spriteData()
      return unless data?.pixels.length

      palette = LOI.Assets.Palette.documents.findOne data.palette._id
      return unless palette

      canvas = $('<canvas>')[0]
      canvas.width = data.bounds.width
      canvas.height = data.bounds.height
      context = canvas.getContext '2d'

      imageData = context.getImageData 0, 0, canvas.width, canvas.height

      for pixel in data.pixels
        x = pixel.x - data.bounds.x
        y = pixel.y - data.bounds.y
        pixelIndex = (x + y * canvas.width) * 4

        indexedColor = data.colorMap[pixel.colorIndex] or
          ramp: 0
          shade: 0

        ramp = indexedColor.ramp

        maxShade = palette.ramps[ramp].shades.length - 1
        shade = THREE.Math.clamp indexedColor.shade + pixel.relativeShade, 0, maxShade

        color = THREE.Color.fromObject palette.ramps[ramp].shades[shade]

        imageData.data[pixelIndex] = color.r * 255
        imageData.data[pixelIndex + 1] = color.g * 255
        imageData.data[pixelIndex + 2] = color.b * 255
        imageData.data[pixelIndex + 3] = 255

      context.putImageData imageData, 0, 0
      @canvas canvas

  draw: ->
    data = @spriteCanvas.drawing.spriteData()
    return unless data?.pixels.length

    canvas = @canvas()
    return unless canvas

    editorContext = @spriteCanvas.context()

    editorContext.imageSmoothingEnabled = false
    editorContext.drawImage canvas, data.bounds.x, data.bounds.y
