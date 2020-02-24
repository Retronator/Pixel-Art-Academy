AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  _computePreviewData: (colorFunctionForHeightAndDirection) ->
    # Compute side preview data.
    viewDirection = new THREE.Vector3()
    data = []

    for x in [0..360]
      data[x] = []
      inclinationDegrees = x - 180
      inclination = AR.Degrees inclinationDegrees
      viewDirection.set Math.sin(inclination), Math.cos(inclination), 0

      for y in [0...@sidePreview.height]
        height = (@sidePreview.height - 1 - y) * @sidePreview.scale
        data[x][y] = colorFunctionForHeightAndDirection height, viewDirection

    @sidePreview.data data

    # Compute hemisphere preview data.
    height = @hemispherePreviewHeight()
    data = []

    for inclinationDegrees in [0..90]
      data[inclinationDegrees] = []
      inclination = AR.Degrees inclinationDegrees
      radius = Math.cos Math.PI / 2 - inclination
      halfCircumference = Math.PI * radius
      azimuthDivisions = Math.max 1, Math.ceil halfCircumference * 45

      for azimuthStep in [0..azimuthDivisions]
        azimuth = Math.PI * azimuthStep / azimuthDivisions

        viewDirection.set Math.sin(inclination) * Math.cos(azimuth), Math.cos(inclination), Math.sin(inclination) * Math.sin(azimuth)

        data[inclinationDegrees][azimuthStep] = colorFunctionForHeightAndDirection height, viewDirection

    @hemispherePreview.data data
