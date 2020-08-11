AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

bitmapSDF = require 'bitmap-sdf'

class AR.Pages.Chemistry.Materials.Scattering extends AR.Pages.Chemistry.Materials.Scattering
  _initializeSurface: ->
    @surfaceCanvas = new ReactiveField null

    @autorun (computation) =>
      if surfaceImageUrl = @surfaceImageUrl()
        image = new Image
        image.crossOrigin = 'Anonymous'
        image.onload = =>
          surfaceCanvas = new AM.Canvas image.width, image.height
          surfaceCanvas.context.drawImage image, 0, 0
          @surfaceCanvas surfaceCanvas

        image.src = surfaceImageUrl

      else
        # Create surface data.
        surfaceSourceWidth = 100
        surfaceSourceHeight = 100
        surfaceCanvas = new AM.Canvas surfaceSourceWidth, surfaceSourceHeight
        surfaceImageData = surfaceCanvas.getFullImageData()

        for x in [0...surfaceSourceWidth]
          surfaceDistance = surfaceSourceHeight * 0.5

          for y in [0...surfaceSourceHeight]
            pixelOffset = (x + y * surfaceSourceWidth) * 4

            if y >= surfaceDistance
              surfaceImageData.data[pixelOffset + i] = 255 for i in [0..2]

            surfaceImageData.data[pixelOffset + 3] = 255

          surfaceCanvas.putFullImageData surfaceImageData

          @surfaceCanvas surfaceCanvas

    # Upscale surface.
    @upscaledSurfaceCanvas = new ComputedField =>
      return unless surfaceCanvas = @surfaceCanvas()
      surfaceUpscaleFactor = @surfaceUpscaleFactor()

      if surfaceUpscaleFactor > 1
        AS.Hqx.scale surfaceCanvas, surfaceUpscaleFactor

      else
        surfaceCanvas

    @size = new ComputedField =>
      return unless upscaledSurfaceCanavs = @upscaledSurfaceCanvas()

      width: upscaledSurfaceCanavs.width
      height: upscaledSurfaceCanavs.height

    # Create signed distance field.
    _surfaceSDFTexture = null
    @surfaceSDFTexture = new ComputedField =>
      return unless upscaledSurfaceCanvas = @upscaledSurfaceCanvas()
      return unless size = @size()

      sdfRadius = Math.max(upscaledSurfaceCanvas.width, upscaledSurfaceCanvas.height) * 2
      surfaceSDF = bitmapSDF upscaledSurfaceCanvas,
        cutoff: 0.5
        radius: sdfRadius

      for i in [0...surfaceSDF.length]
        surfaceSDF[i] = (-surfaceSDF[i] + 0.5) * sdfRadius

      _surfaceSDFTexture?.dispose()

      _surfaceSDFTexture = new THREE.DataTexture surfaceSDF, size.width, size.height, THREE.AlphaFormat, THREE.FloatType
      _surfaceSDFTexture.minFilter = THREE.LinearFilter
      _surfaceSDFTexture.magFilter = THREE.LinearFilter

      _surfaceSDFTexture

    @surfaceHelpers = new ComputedField =>
      return unless size = @size()

      rayTarget: new THREE.Vector3 size.width / 2, size.height / 2, 0
      canvasBox: new THREE.Box3 new THREE.Vector3(), new THREE.Vector3(size.width, size.height, 0)
      rayIntersectionDistance: size.width + size.height
