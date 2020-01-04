AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  @register 'Artificial.Reality.Pages.Optics.Scattering'

  drawRayleighScattering: ->
    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    offsetLeft = 10
    offsetTop = 10
    context.translate offsetLeft + 0.5, offsetTop + 0.5

    preview =
      width: 200
      height: 150
      scale: 100 # 1px = 100m

    volume =
      left: 50
      top: 50
      width: 100
      height: 50

    # Draw incident light ray.
    y = volume.top + volume.height * 0.5

    context.beginPath()
    context.moveTo 0, y
    context.lineTo volume.left, y
    context.strokeStyle = 'white'
    context.stroke()

    # Draw transmitted light ray.
    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    transmittedLightXYZ = AS.Color.CIE1931.getXYZForSpectrum (wavelength) =>
      D65EmissionSpectrum(wavelength)

    transmittedLightRGB = AS.Color.SRGB.getRGBForXYZ transmittedLightXYZ
    transmittedLightStyle = "rgb(#{transmittedLightRGB.r * 255}, #{transmittedLightRGB.g * 255}, #{transmittedLightRGB.b * 255})"

    context.beginPath()
    context.moveTo volume.left + volume.width, y
    context.lineTo preview.width, y
    context.strokeStyle = transmittedLightStyle
    context.stroke()

    # Draw the volume.
    context.strokeStyle = 'gainsboro'
    context.lineWidth = 1
    context.globalAlpha = 0.2
    context.strokeRect volume.left, volume.top, volume.width, volume.height
    context.globalAlpha = 1

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, preview.width, preview.height

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "distance (km)", 90, 190

    context.beginPath()

    for x in [0..preview.width] by 50
      # Write the number on the axis.
      xKilometers = Math.round x * preview.scale / 1e3

      context.textAlign = 'center'
      context.fillText xKilometers, x, preview.height + 16
