AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3
hues = LOI.Assets.Palette.Atari2600.hues

class C3.Design.Terminal.Properties.Color extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Color'

  @Presets:
    Default:
      width: 9
      hues: [
        hues.grey
        hues.red
        hues.peach
        hues.orange
        hues.yellow
        hues.brown
        hues.olive
        hues.lime
        hues.green
        hues.aqua
        hues.cyan
        hues.azure
        hues.blue
        hues.indigo
        hues.purple
        hues.magenta
      ]
      defaultHue: hues.grey
      shades: [1, 2, 3, 4, 5, 6, 7, 8]
      defaultShade: 6
      huePreviewShade: 4

    Skin:
      width: 7
      hues: [
        hues.red
        hues.peach
        hues.orange
        hues.yellow
        hues.brown
        hues.olive
        hues.lime
        hues.green
        hues.aqua
        hues.cyan
        hues.azure
        hues.blue
        hues.indigo
        hues.purple
        hues.magenta
        hues.grey
      ]
      defaultHue: hues.peach
      shades: [1, 2, 3, 4, 5, 6, 7]
      defaultShade: 4
      huePreviewShade: 4

  onCreated: ->
    super

    @property = @data()

    @colors = @property.options.colors
    @colors ?= @constructor.Presets[@property.options.colorsPresetName] if @property.options.colorsPresetName
    @colors ?= @constructor.Presets.Default

    @selectedHue = new ComputedField =>
      # Try to load from property data.
      colorNode = @property.options.dataField()
      return hue if hue = colorNode? 'hue'

      @colors.defaultHue or 0

    @selectedShade = new ComputedField =>
      # Try to load from property data.
      colorNode = @property.options.dataField()
      return shade if shade = colorNode? 'shade'

      @colors.defaultShade or 0

    @pageNumber = {}
    @pagesCount = {}
    @currentColorIndices = {}

    for row in ['hues', 'shades']
      do (row) =>
        @pageNumber[row] = new ReactiveField 0

        @pagesCount[row] = new ComputedField =>
          if @colors[row].length <= @colors.width
            1

          else if @colors[row].length <= (@colors.width - 1) * 2
            2

          else
            2 + Math.floor(@colors[row].length - (@colors.width - 1) * 2) / (@colors.width - 2)

        @currentColorIndices[row] = new ComputedField =>
          pageNumber = @pageNumber[row]()
          swatchesCount = @colors.width - 2
          startIndex = 0

          if pageNumber is 0 or pageNumber is @pagesCount[row]() - 1
            swatchesCount++

            if pageNumber is 0 and @pagesCount[row]() is 1
              swatchesCount = @colors[row].length

          if pageNumber > 0
            startIndex += (@colors.width - 1) + (@colors.width - 2) * (pageNumber - 1)
            endIndex = startIndex + swatchesCount - 1

            if endIndex > @colors[row].length
              swatchesCount = @colors[row].length - startIndex

          for colorIndex in [startIndex...startIndex + swatchesCount]
            @colors[row][colorIndex]

  hues: ->
    selectedHue = @selectedHue()
    selectedShade = @selectedShade()
    previewShade = @colors.huePreviewShade ? selectedShade
    palette = LOI.palette()

    swatches: for hueIndex in @currentColorIndices.hues()
      color: palette.color hueIndex, previewShade
      value: hueIndex
      selected: hueIndex is selectedHue
    hasPreviousPage: @pageNumber.hues() > 0
    hasNextPage: @pageNumber.hues() < @pagesCount.hues() - 1
    pageNumber: @pageNumber.hues
    save: (value) =>
      @property.options.dataField
        hue: value
        shade: selectedShade

  shades: ->
    selectedHue = @selectedHue()
    selectedShade = @selectedShade()
    palette = LOI.palette()

    swatches: for shadeIndex in @currentColorIndices.shades()
      color: palette.color selectedHue, shadeIndex
      value: shadeIndex
      selected: shadeIndex is selectedShade
    hasPreviousPage: @pageNumber.shades() > 0
    hasNextPage: @pageNumber.shades() < @pagesCount.shades() - 1
    pageNumber: @pageNumber.shades
    valueField: @selectedShade
    save: (value) =>
      @property.options.dataField
        hue: selectedHue
        shade: value

  # Components

  class @Swatches extends AM.Component
    @register 'SanFrancisco.C3.Design.Terminal.Properties.Color.Swatches'

    selectedClass: ->
      swatch = @currentData()

      'selected' if swatch.selected

    swatchStyle: ->
      swatch = @currentData()
      
      backgroundColor: "##{swatch.color.getHexString()}"

    events: ->
      super.concat
        'click .swatch': @onClickSwatch
        'click .previous-page-button': @onClickPreviousPageButton
        'click .next-page-button': @onClickNextPageButton

    onClickSwatch: (event) ->
      swatchesData = @data()
      swatch = @currentData()
      swatchesData.save swatch.value

    onClickPreviousPageButton: (event) ->
      swatchesData = @data()
      swatchesData.pageNumber swatchesData.pageNumber() - 1

    onClickNextPageButton: (event) ->
      swatchesData = @data()
      swatchesData.pageNumber swatchesData.pageNumber() + 1
