AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3
hues = LOI.Assets.Palette.Atari2600.hues

class C3.Design.Terminal.Properties.HairColor extends C3.Design.Terminal.Properties.Color
  @register 'SanFrancisco.C3.Design.Terminal.Properties.HairColor'

  onCreated: ->
    super arguments...

    @selectedShine = new ComputedField =>
      @property.shine()

    @selectedShineValue

    @pageNumber.shineLevels = => 0
    @pagesCount.shineLevels = => 1
    @currentColorIndices.shineLevels = => [0..4]

  shineLevels: ->
    selectedShine = @selectedShine()
    palette = LOI.palette()

    swatches: for shadeIndex in @currentColorIndices.shineLevels()
      color: palette.color 0, shadeIndex + 1
      value: shadeIndex
      selected: shadeIndex is selectedShine
    valueField: @selectedShine
    save: (value) =>
      shineLocation = @property.options.dataLocation.child 'shine'
      shineLocation value
