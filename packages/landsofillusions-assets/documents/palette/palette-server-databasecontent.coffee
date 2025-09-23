AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions

PNG = require 'fast-png'

class LOI.Assets.Palette extends LOI.Assets.Palette
  @Meta
    name: @id()
    replaceParent: true

  @deserializeDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AMu.EmbeddedImageData.extract imageData

  getDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()

    previewImage = @getPreviewImage()
    imageData = AMu.EmbeddedImageData.embed previewImage, @

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData
  
    plainData: @
    arrayBuffer: arrayBuffer
    path: "landsofillusions/assets/documents/palette/#{@name or @_id}.png"
    lastEditTime: @lastEditTime

  getPreviewImage: ->
    # Figure out how big the canvas needs to be to incorporate all
    longestRamp = _.maxBy @ramps, (ramp) => ramp.shades.length
    maxShades = longestRamp.shades.length
    scale = 20
  
    measureCanvas = new AM.Canvas 1, 1
    
    nameWidths = (measureCanvas.context.measureText(ramp.name).width for ramp in @ramps when ramp.name)
    namesWidth = if nameWidths.length then _.max(nameWidths) + scale else scale * 0.5

    canvas = new AM.Canvas namesWidth + (maxShades + 0.5) * scale, (@ramps.length + 1) * scale
    canvas.context.textBaseline = 'middle'
    
    # Draw swatches to canvas.
    for ramp, rampIndex in @ramps
      if ramp.name
        canvas.context.fillStyle = "black"
        canvas.context.fillText ramp.name, 0.5 * scale, (rampIndex + 1) * scale

      for shade, shadeIndex in ramp.shades
        canvas.context.fillStyle = "rgb(#{shade.r * 255},#{shade.g * 255},#{shade.b * 255})"
        canvas.context.fillRect namesWidth + shadeIndex * scale, (rampIndex + 0.5) * scale, scale, scale
  
    canvas
