AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Display extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Store.Display'
  @url: -> 'retronator/store/display'

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

    @smiling = new ReactiveField false

  smile: ->
    @smiling true

    Meteor.setTimeout =>
      @smiling false
    ,
      5500

  # Listener

  onCommand: (commandResponse) ->
    display = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], display.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem display

  # Component

  onCreated: ->
    super

    @subscribe RS.Transactions.Transaction.topRecent

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
    
  topRecentTransactions: ->
    # Get top recent transactions from the receipt.
    if receipt = LOI.adventure.getCurrentThing HQ.Items.Receipt
      return receipt.topRecentTransactions() if receipt.totalPrice()

    # We couldn't get to receipt's modified transactions so just show the unmodified ones.
    RS.Components.TopSupporters.topRecentTransactions.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]
