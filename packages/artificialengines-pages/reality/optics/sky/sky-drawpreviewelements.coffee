AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  _drawPreviewElements: ->
    @_drawSidePreviewElements()
    @_drawHemispherePreviewElements()
    @_drawSkydomePreviewElements()

  _drawSidePreviewElements: ->
    # Draw side preview elements.
    @context.setTransform 1, 0, 0, 1, @offsetLeft + 0.5, @offsetTop + 0.5

    # Draw the border.
    @context.strokeStyle = 'ghostwhite'
    @context.strokeRect 0, 0, @sidePreview.width, @sidePreview.height

    # Draw scale.
    @context.fillStyle = 'ghostwhite'
    @context.font = '12px "Source Sans Pro", sans-serif'

    @context.textAlign = 'center'
    @context.fillText "inclination (°)", @sidePreview.width / 2, @sidePreview.height + 35

    @context.save()
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.rotate -Math.PI / 2
    @context.fillText "Height (km)", -(@sidePreview.height / 2) - 10, 30
    @context.restore()

    @context.beginPath()

    for x in [0..360] by 30
      # Write the number on the axis.
      @context.textAlign = 'center'
      @context.fillText x - 180, x, @sidePreview.height + 16

    for y in [0..@sidePreview.height] by 25
      # Write the number on the y axis.
      @context.textAlign = 'right'
      @context.fillText y, -8, @sidePreview.height - y + 4

  _drawHemispherePreviewElements: ->
    @context.setTransform 1, 0, 0, 1, @offsetLeftHemisphere + 0.5, @offsetTopHemisphere + 0.5

    # Draw the border.
    @context.strokeStyle = 'ghostwhite'
    @context.beginPath()
    @context.arc @hemispherePreview.width / 2 - 0.5, @hemispherePreview.height / 2 - 0.5, @hemispherePreview.width / 2 - 0.5, 0, Math.PI * 2
    @context.stroke()

    # Draw scale.
    @context.fillStyle = 'ghostwhite'
    @context.font = '12px "Source Sans Pro", sans-serif'

    @context.textAlign = 'center'
    @context.fillText "azimuth (°)", @hemispherePreview.width / 2, @hemispherePreview.height + 35

    @context.beginPath()

    # Write the number on the axis.
    for azimuthDegrees in [180..-179] by -15
      azimuth = AR.Degrees azimuthDegrees
      @context.textAlign = 'center'
      x = @hemispherePreview.width / 2 + @hemispherePreview.width * 0.59 * Math.cos(azimuth)
      y = @hemispherePreview.height / 2 + 3 + @hemispherePreview.height * 0.57 * Math.sin(azimuth)
      @context.fillText azimuthDegrees, x, y

  _drawSkydomePreviewElements: ->
    @context.setTransform 1, 0, 0, 1, @offsetLeftSkydome + 0.5, @offsetTopSkydome + 0.5

    # Draw the border.
    @context.strokeStyle = 'ghostwhite'
    @context.strokeRect 0, 0, @skydomePreview.width, @skydomePreview.height

    # Draw scale.
    @context.fillStyle = 'ghostwhite'
    @context.font = '12px "Source Sans Pro", sans-serif'

    @context.textAlign = 'center'
    @context.fillText "azimuth (°)", @skydomePreview.width / 2, @skydomePreview.height + 35

    @context.save()
    @context.setTransform 1, 0, 0, 1, @offsetLeftSkydome - @offsetLeft, @offsetTopSkydome
    @context.rotate -Math.PI / 2
    @context.fillText "inclination (°)", -(@skydomePreview.height / 2), 30
    @context.restore()

    @context.beginPath()

    for x in [0..360] by 30
      # Write the number on the axis.
      @context.textAlign = 'center'
      @context.fillText x - 180, x, @skydomePreview.height + 16

    for y in [0..90] by 30
      # Write the number on the y axis.
      @context.textAlign = 'right'
      @context.fillText y, -8, y + 4
