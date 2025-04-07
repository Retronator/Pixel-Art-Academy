AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy

import * as StackBlur from 'stackblur-canvas'

paletteGlowBlendingDuration = 0.5
manualRotationBlendingRate = 0.99

class PAA.PixelPad.Apps.Drawing.PaletteSelection extends PAA.PixelPad.Apps.Drawing.PaletteSelection
  @register @id()
  
  onCreated: ->
    super arguments...

    @currentPalette = new ComputedField =>
      return unless currentPageIndex = @currentPageIndex()
      @_getPaletteOnPage currentPageIndex
    
    @nextPalette = new ComputedField =>
      return unless currentPageIndex = @currentPageIndex()
      @_getPaletteOnPage currentPageIndex + 1
      
  onRendered: ->
    super arguments...
    
    @paletteGlowCanvas = new AM.ReadableCanvas 480, 360
    @$('.background').append @paletteGlowCanvas
    
    @_paletteGlowImageData = @paletteGlowCanvas.getFullImageData()
    @_sourcePalleteGlowImageData = @paletteGlowCanvas.context.createImageData 480, 360
    @_paletteGlowBlendingPalette = null
    @_paletteGlowBlendingElapsedTime = 0
    @_paletteGlowBlendingWasManual = false
    
    @_paletteGlowImageDatas = {}
    
    # Render palette glows and go to the initial page.
    @autorun (computation) =>
      return unless @activatable.activated()
      return unless sections = @sections()

      for section in sections
        @_createPaletteGlowImageDataForPalette palette for palette in section.palettes

      return unless @initialTargetPaletteName
      
      for section in sections
        for palette, paletteIndex in section.palettes
          if palette.name is @initialTargetPaletteName
            @goToPage section.separatorPageIndex + paletteIndex + 1
            delete @initialTargetPaletteName
            return
    
  _createPaletteGlowImageDataForPalette: (palette) ->
    return if @_paletteGlowImageDatas[palette.name]
    
    @_paletteGlowImageDatas[palette.name] = @paletteGlowCanvas.context.createImageData 480, 360
    data = @_paletteGlowImageDatas[palette.name].data
    
    colorRows = PAA.PixelPad.Apps.Drawing.PaletteSelection.splitPaletteIntoColorRows palette
    
    for rowColors, rowIndex in colorRows
      for color, colorIndex in rowColors
        left = Math.floor colorIndex / rowColors.length * 480
        right = Math.min 479, Math.ceil (colorIndex + 1) / rowColors.length * 480
        top = Math.floor rowIndex / colorRows.length * 360
        bottom = Math.min 359, Math.ceil (rowIndex + 1) / colorRows.length * 360
        
        for x in [left..right]
          for y in [top..bottom]
            dataIndex = (y * 480 + x) * 4
            
            data[dataIndex] = color.r * 255
            data[dataIndex + 1] = color.g * 255
            data[dataIndex + 2] = color.b * 255
            data[dataIndex + 3] = 255
      
    StackBlur.imageDataRGBA @_paletteGlowImageDatas[palette.name], 0, 0, 480, 360, 150

    ditherSize = 8
    quantizationFactor = 16
    @_paletteGlowDitherThresholdMap ?= AS.PixelArt.getDitherThresholdMap ditherSize
    
    for y in [0...360]
      for x in [0...480]
        pixelOffset = (y * 480 + x) * 4
        
        ditherX = x % ditherSize
        ditherY = y % ditherSize
        ditherAmount = @_paletteGlowDitherThresholdMap[ditherY][ditherX]
        
        for channelOffset in [0..2]
          valueOffset = pixelOffset + channelOffset
          value = data[valueOffset]
          
          # Bring value to quantized range.
          value = value / 256 * quantizationFactor
          
          # Add dither.
          value += ditherAmount - 0.5
          
          # Quantize and scale back to byte range.
          data[valueOffset] = Math.round(value) / quantizationFactor * 256
    
  _updatePaletteGlow: (appTime) ->
    return unless @_paletteGlowImageDatas
    
    targetData = @_paletteGlowImageData.data
    
    if @manualPageRotation
      @_paletteGlowBlendingWasManual = true
      currentPalette = @currentPalette()
      nextPalette = @nextPalette()
      
      currentPaletteImageData = @_paletteGlowImageDatas[currentPalette.name] if currentPalette
      nextPaletteImageData = @_paletteGlowImageDatas[nextPalette.name] if nextPalette
      
      proportion = _.clamp @manualPageRotation / 90, 0, 1
      
      for x in [0...480]
        for y in [0...360]
          dataIndex = (y * 480 + x) * 4
          
          decayProportion = 1 - (1 - manualRotationBlendingRate) ** appTime.elapsedAppTime
          
          for offset in [0..2]
            targetValue = @_blendColor currentPaletteImageData?.data[dataIndex + offset], nextPaletteImageData?.data[dataIndex + offset], proportion
            targetData[dataIndex + offset] = @_blendColor targetData[dataIndex + offset], targetValue, decayProportion
          
          targetValue = @_blendAlpha currentPaletteImageData?.data[dataIndex + 3], nextPaletteImageData?.data[dataIndex + 3], proportion
          targetData[dataIndex + 3] = @_blendAlpha targetData[dataIndex + 3], targetValue, decayProportion
    
    else
      currentPalette = @currentPalette()
      currentPaletteImageData = @_paletteGlowImageDatas[currentPalette.name] if currentPalette
      
      if currentPalette is @_paletteGlowBlendingPalette and not @_paletteGlowBlendingWasManual
        return if @_paletteGlowBlendingElapsedTime > paletteGlowBlendingDuration
        
        # Continue blending from the source to the current palette.
        @_paletteGlowBlendingElapsedTime = Math.min paletteGlowBlendingDuration, @_paletteGlowBlendingElapsedTime + appTime.elapsedAppTime
        proportion = @_paletteGlowBlendingElapsedTime / paletteGlowBlendingDuration
        
        for x in [0...480]
          for y in [0...360]
            dataIndex = (y * 480 + x) * 4
            
            for offset in [0..2]
              targetData[dataIndex + offset] = @_blendColor @_sourcePalleteGlowImageData.data[dataIndex + offset], currentPaletteImageData?.data[dataIndex + offset], proportion
            
            targetData[dataIndex + 3] = @_blendAlpha @_sourcePalleteGlowImageData.data[dataIndex + 3], currentPaletteImageData?.data[dataIndex + 3], proportion
      
      else
        # Reset the source.
        @_sourcePalleteGlowImageData.data.set @_paletteGlowImageData.data
        @_paletteGlowBlendingPalette = @currentPalette()
        @_paletteGlowBlendingElapsedTime = 0
        
        @_paletteGlowBlendingWasManual = false
      
    @paletteGlowCanvas.putFullImageData @_paletteGlowImageData
    
  _blendColor: (colorValue1, colorValue2, proportion) ->
    return colorValue1 unless colorValue2?
    return colorValue2 unless colorValue1?
    THREE.MathUtils.lerp colorValue1, colorValue2, proportion
    
  _blendAlpha: (alphaValue1 = 0, alphaValue2 = 0, proportion) ->
    THREE.MathUtils.lerp alphaValue1, alphaValue2, proportion
