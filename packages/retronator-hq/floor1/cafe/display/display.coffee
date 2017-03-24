AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Cafe.Display extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Cafe.Display'
  @url: -> 'retronator/cafe/display'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "supporters display"
  @shortName: -> "display"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a big screen showing a list of people and their contributions.
    "

  @initialize()

  constructor: ->
    super

  onCreated: ->
    super

    @subscribe RS.Transactions.Transaction.topRecent
    @subscribe RA.User.topSupporters

    @_messagesCount = new ReactiveField 20

    @autorun (computation) =>
      @subscribe RS.Transactions.Transaction.messages, @_messagesCount()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      # HACK: Deactivate item on adventure first to prevent a render component error. TODO: Figure out why.
      LOI.adventure.deactivateCurrentItem()
      finishedDeactivatingCallback()
    ,
      500

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

  # Listener

  onCommand: (commandResponse) ->
    display = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], display.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem display
