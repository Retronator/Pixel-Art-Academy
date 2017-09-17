AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Renders a sprite asset to a canvas.
class LOI.Components.Sprite extends AM.Component
  @register 'LandsOfIllusions.Components.Sprite'

  onRendered: ->
    super
    
    $canvas = @$('.landsofillusions-components-sprite')
    canvas = $canvas[0]
    context = canvas.getContext '2d'
    
    # Subscribe to this sprite's palette.
    @autorun (computation) =>
      spriteData = @data()
      
      LOI.Assets.Palette.forId.subscribe @, spriteData.palette._id

    @autorun (computation) =>
      spriteData = @data()
      return unless spriteData?.pixels.length

      palette = LOI.Assets.Palette.documents.findOne spriteData.palette._id
      return unless palette

      canvas.width = spriteData.bounds.width
      canvas.height = spriteData.bounds.height

      imageData = context.getImageData 0, 0, canvas.width, canvas.height

      for pixel in spriteData.pixels
        x = pixel.x - spriteData.bounds.x
        y = pixel.y - spriteData.bounds.y
        pixelIndex = (x + y * canvas.width) * 4

        indexedColor = spriteData.colorMap[pixel.colorIndex] or
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
