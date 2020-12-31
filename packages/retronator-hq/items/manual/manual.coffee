AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.Manual extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Manual'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Manual'
  @url: -> 'manual'

  @fullName: -> "Adventure Manual"

  @description: ->
    "
      Instructions for playing text adventures.
    "

  @initialize()

  onCreated: ->
    super arguments...
