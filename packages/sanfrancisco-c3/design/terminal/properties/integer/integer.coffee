AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Integer extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Integer'

  onCreated: ->
    super

    property = @data()
    @input = new @constructor.Input property.options.dataLocation

  class @Input extends AM.DataInputComponent
    constructor: (@dataLocation) ->
      super

      @type = AM.DataInputComponent.Types.Number

    load: ->
      @dataLocation()

    save: (value) ->
      @dataLocation parseInt value
