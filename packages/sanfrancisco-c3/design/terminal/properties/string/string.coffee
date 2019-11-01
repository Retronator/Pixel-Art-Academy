AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.String extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.String'

  onCreated: ->
    super arguments...

    property = @data()
    @input = new C3.Design.Terminal.Properties.Input property.options
