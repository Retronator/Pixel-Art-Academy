AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet extends LOI.Adventure.Item
  @register 'Retronator.HQ.Items.Tablet'
  template: -> 'Retronator.HQ.Items.Tablet'

  @id: -> 'Retronator.HQ.Items.Tablet'
  @url: -> 'spectrum'

  @fullName: -> "Spectrum tablet"

  @shortName: -> "tablet"

  @description: ->
    "
      It's the latest model of the signature Retronator Spectrum Tablet, used to interact around Retronator HQ.
    "

  @initialize()

  onCreated: ->
    super
