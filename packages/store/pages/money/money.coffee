AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Money extends AM.Component
  @register 'Retronator.Store.Pages.Money'

  onCreated: ->
    super

    @subscribe 'Retronator.Accounts.Transactions.Transaction.topRecent'
    @subscribe 'Retronator.Accounts.User.topSupporters'

    @_messagesCount = new ReactiveField 20

    @autorun (computation) =>
      @subscribe 'Retronator.Accounts.Transactions.Transaction.messages', @_messagesCount()

  topRecentTransactions: ->
    # Get the existing top 10.
    RS.Components.TopSupporters.topRecentTransactions.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]

  topSupporters: ->
    # Get the existing top 10.
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
