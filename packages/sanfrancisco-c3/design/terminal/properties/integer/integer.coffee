AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Integer extends C3.Design.Terminal.Properties.Number
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Integer'

  class @Input extends C3.Design.Terminal.Properties.Number.Input
    save: (value) ->
      value = parseInt value if value?.length
      super value
