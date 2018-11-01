AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.LocationSelect extends AM.DataInputComponent
  @register 'LandsOfIllusions.Assets.AudioEditor.LocationSelect'

  constructor: ->
    super arguments...

    @type = AM.DataInputComponent.Types.Select

  onCreated: ->
    super arguments...

    @audioEditor = @ancestorComponentOfType LOI.Assets.AudioEditor

  options: ->
    locationClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) =>
      thingClass.prototype instanceof LOI.Adventure.Location

    currentValue = @load()

    options = for locationClass in locationClasses when locationClass.fullName()
      name: if locationClass.id() is currentValue then _.upperFirst locationClass.fullName() else locationClass.id()
      value: locationClass.id()

    options = _.sortBy options, 'value'

    # Add empty option
    options.unshift
      name: ''
      value: null

    options

  load: ->
    @audioEditor.audioData()?.editor?.locationId

  save: (value) ->
    LOI.Assets.Asset.update LOI.Assets.Audio.className, @audioEditor.audioId(),
      $set:
        'editor.locationId': value
