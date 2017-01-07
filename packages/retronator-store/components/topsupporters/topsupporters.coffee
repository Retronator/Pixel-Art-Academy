AB = Artificial.Babel
AM = Artificial.Mirage
RS = Retronator.Store

class RS.Components.TopSupporters extends AM.Component
  @register 'Retronator.Store.Components.TopSupporters'

  if Meteor.isClient
    @topRecentTransactions = new Meteor.Collection 'TopRecentTransactions'
    @topSupporters = new Meteor.Collection 'TopSupporters'
    @transactionMessages = new Meteor.Collection 'TransactionMessages'

  supporters: ->
    @data()
 
  supporterClass: ->
    transaction = @currentData()

    'new' if transaction.new
  
  name: ->
    transaction = @currentData()
    transaction.name or @anonymousPlaceholder()

  anonymousPlaceholder: ->
    AB.translate(@_userBabelSubscription, 'Anonymous').text
