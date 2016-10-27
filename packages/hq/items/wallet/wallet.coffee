AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Wallet extends LOI.Adventure.Item
  template: -> 'Retronator.HQ.Items.Wallet'

  @id: -> 'Retronator.HQ.Items.Wallet'
  @url: -> 'signin'

  @fullName: -> "wallet"

  @shortName: -> "wallet"

  @description: ->
    "
      It's your wallet, very useful for holding your IDs. Use it at the reception desk to sign in.
    "

  @initialize()
