AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AdventureView.LocationSelect extends AM.DataInputComponent
  @register 'LandsOfIllusions.Assets.AudioEditor.AdventureView.LocationSelect'

  constructor: ->
    super arguments...

    @type = AM.DataInputComponent.Types.Select

  onCreated: ->
    super arguments...

    @adventureView = @ancestorComponentOfType LOI.Assets.AudioEditor.AdventureView

  options: ->
    locationClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) =>
      thingClass.prototype instanceof LOI.Adventure.Location

    currentValue = @load()

    options = for locationClass in locationClasses when locationClass.fullName()
      name: if locationClass.id() is currentValue then _.upperFirst locationClass.fullName() else locationClass.id()
      value: locationClass.id()

    options = _.sortBy options, 'value'

    # Add the empty option.
    options.unshift
      name: ''
      value: null

    options

  load: ->
    @adventureView.locationId()

  save: (value) ->
    @adventureView.locationId value
