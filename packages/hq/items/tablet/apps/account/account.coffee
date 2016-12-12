AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.Account extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Account'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Account'
  @url: -> 'account'

  @fullName: -> "Account File"

  @description: ->
    "
      It's a all the documents with details about your account at Retronator.
    "

  @initialize()

  onCreated: ->
    super
