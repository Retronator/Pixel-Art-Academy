AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Input extends AM.DataInputComponent
  # Note: We can't name the constructor argument simply options because that is reserved for select input options.
  constructor: (@inputOptions) ->
    super arguments...

    @type = AM.DataInputComponent.Types.Select if @inputOptions.values

  options: ->
    options = for option in @inputOptions.values
      name: option
      value: option

    unless @load()
      options.unshift
        name: ''
        value: null

    options

  load: ->
    @inputOptions.dataLocation()

  save: (value) ->
    value = null if _.isString value and not value?.length
    @inputOptions.dataLocation value
