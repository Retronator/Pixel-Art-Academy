AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.AccountFile extends LOI.Adventure.Item
  @register 'Retronator.HQ.Items.AccountFile'
  template: -> 'Retronator.HQ.Items.AccountFile'

  @id: -> 'Retronator.HQ.Items.AccountFile'
  @url: -> 'account'

  @fullName: -> "account file"

  @shortName: -> "account"

  @description: ->
    "
      It's a bunch of documents with details about your account at Retronator.
    "

  @initialize()

  onCreated: ->
    super
