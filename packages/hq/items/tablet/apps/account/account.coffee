AB = Artificial.Babel
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

  class @SupporterName extends AM.DataInputComponent
    @register 'Retronator.HQ.Items.Tablet.Apps.Account.SupporterName'

    onCreated: ->
      super

      @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'
      @_receiptBabelSubscription = AB.subscribeNamespace 'Retronator.HQ.Items.Tablet.Apps.ShoppingCart.Receipt'

    load: ->
      Retronator.user()?.profile?.supporterName

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.setSupporterName", value

    placeholder: ->
      AB.translate(@_receiptBabelSubscription, 'Your name here').text
