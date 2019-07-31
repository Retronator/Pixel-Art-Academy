AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3
hues = LOI.Assets.Palette.Atari2600.hues

class C3.Design.Terminal.Properties.OutfitColor extends C3.Design.Terminal.Properties.Color
  @register 'SanFrancisco.C3.Design.Terminal.Properties.OutfitColor'

  onCreated: ->
    super arguments...

    @properties = [
      name: 'intensity'
      inputOptions:
        min: 0
        max: 2
        step: 0.1
        default: 0
    ,
      name: 'shininess'
      inputOptions:
        min: 0
        max: 50
        step: 1
        default: 1
    ,
      name: 'smoothing'
      propertyName: 'smoothFactor'
      inputOptions:
        min: 0
        max: 3
        step: 1
        default: 0
    ]

    outfitColorProperty = @data()

    for property in @properties
      property.propertyName ?= property.name
      property.inputOptions.dataLocation = outfitColorProperty.options.dataLocation.child "reflection.#{property.propertyName}"
      property.input = new C3.Design.Terminal.Properties.Number.Input property.inputOptions
