AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3
hues = LOI.Assets.Palette.Atari2600.hues

class C3.Design.Terminal.Properties.RelativeColorShade extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.RelativeColorShade'

  onCreated: ->
    super

    # TODO: Make property reactive to data change.
    @property = @data()

    @selectedRelativeShade = new ComputedField =>
      @property.relativeShade()

    swatchesPerPage = @property.options.swatchesPerPage or 5
    @pageNumber = new ReactiveField 0

    @currentRelativeShades = new ComputedField =>
      pageNumber = @pageNumber()
      startIndex = 0 - Math.floor(swatchesPerPage / 2) + pageNumber * swatchesPerPage

      [startIndex...startIndex + swatchesPerPage]

  shades: ->
    hue = @property.hue() or 0
    baseShade = @property.baseShade() or 4
    selectedRelativeShade = @selectedRelativeShade()
    palette = LOI.palette()

    swatches: for relativeShade in @currentRelativeShades()
      color: palette.color hue, baseShade + relativeShade
      value: relativeShade
      selected: relativeShade is selectedRelativeShade
    pageNumberField: @pageNumber
    valueField: @selectedRelativeShade
    save: (value) =>
      @property.options.dataLocation value

  # Components

  class @Swatches extends AM.Component
    @register 'SanFrancisco.C3.Design.Terminal.Properties.RelativeColorShade.Swatches'

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
      swatchesData.pageNumberField swatchesData.pageNumberField() - 1

    onClickNextPageButton: (event) ->
      swatchesData = @data()
      swatchesData.pageNumberField swatchesData.pageNumberField() + 1
