AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Boolean extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Boolean'

  onCreated: ->
    super arguments...

    property = @data()
    @input = new @constructor.Input property.options

  class @Input extends C3.Design.Terminal.Properties.Input
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox
