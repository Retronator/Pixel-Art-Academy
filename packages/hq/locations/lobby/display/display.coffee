AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Lobby.Display extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Locations.Lobby.Display'
  @url: -> 'retronator/lobby/display'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "supporters display"

  @shortName: -> "display"

  @description: ->
    "
      It's a big screen showing a list of people and their contributions.
    "

  @initialize()

  constructor: ->
    super

    @addAbilityLook()

  onCreated: ->
    super

    @subscribe RS.Transactions.Transaction.topRecent
    @subscribe RA.User.topSupporters

    @_messagesCount = new ReactiveField 20

    @autorun (computation) =>
      @subscribe RS.Transactions.Transaction.messages, @_messagesCount()

  topRecentTransactions: ->
    RS.Components.TopSupporters.topRecentTransactions.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]

  topSupporters: ->
    RS.Components.TopSupporters.topSupporters.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]

  transactionMessages: ->
    # Show all the transaction messages not already shown in the top 10 recent transactions.
    topRecentTransactionIds = _.map @topRecentTransactions().fetch(), '_id'

    RS.Components.TopSupporters.transactionMessages.find
      _id:
        $nin: topRecentTransactionIds
    ,
      sort:
        time: -1
