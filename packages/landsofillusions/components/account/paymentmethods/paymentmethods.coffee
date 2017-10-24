AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class LOI.Components.Account.PaymentMethods extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.PaymentMethods'
  @url: -> 'payment-methods'
  @displayName: -> 'Payment methods'

  @initialize()
