AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Number extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Number'

  onCreated: ->
    super arguments...

    property = @data()
    @input = new @constructor.Input property.options

  class @Input extends C3.Design.Terminal.Properties.Input
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number unless @inputOptions.values

      @customAttributes = {}
      for property in ['min', 'max', 'step']
        @customAttributes[property] = @inputOptions[property] if @inputOptions[property]?

      @placeholder = @inputOptions.default

    save: (value) ->
      value = parseFloat value if value?.length
      super value
