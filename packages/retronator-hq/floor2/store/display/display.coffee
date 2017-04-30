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

  @Views:
    Center: 'Center'
    Left: 'Left'

  constructor: ->
    super

    @smiling = new ReactiveField false

    @view = new ReactiveField @constructor.Views.Center
    @showReceiptSupporters = new ReactiveField false

  smile: ->
    @smiling true

    Meteor.setTimeout =>
      @smiling false
    ,
      5500

  viewClass: ->
    _.lowerCase @view()

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

    @subscribe RS.Transactions.Transaction.topRecent, 15
    @subscribe RA.User.topSupportersCurrentUser

    @_topSupportersCount = new ReactiveField 10

    @autorun (computation) =>
      @subscribe RA.User.topSupporters, @_topSupportersCount()

    @_messagesCount = new ReactiveField 50

    @autorun (computation) =>
      @subscribe RS.Transactions.Transaction.messages, @_messagesCount()

  onRendered: ->
    super

    # Fix supporter list titles to be inside the screen.
    $supportersArea = @$('.content-area .supporters-area')
    $supportersListTitles = @$('.supporters-list-titles')
    $supportersListTitlesTitles = $supportersListTitles.find('.title')

    $contentArea = @$('.content-area')

    $contentArea.scroll (event) =>
      scrollTop = $contentArea.scrollTop()
      areaHeight = $supportersArea.outerHeight()
      titleHeight = $supportersListTitlesTitles.outerHeight()

      # Make sure the title still stays inside supporters area.
      titleBottom = scrollTop + titleHeight
      titleOffset = Math.min areaHeight - titleBottom, 0

      $supportersListTitles.css top: titleOffset

    # HACK: For unknown reason, events method does not work?!?
    @$('.top-supporters .show-more-button').click (event) =>
      @_topSupportersCount @_topSupportersCount() + 40

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
    
  topRecentTransactions: ->
    if @showReceiptSupporters()
      # Get top recent transactions from the receipt.
      receipt = LOI.adventure.getCurrentThing HQ.Items.Receipt

      # Make sure that receipt exists, since it could disappear from state (for example, multiple browsers).
      return receipt.topRecentTransactions() if receipt

    # Show normal supporters list otherwise.
    RS.Components.TopSupporters.topRecentTransactions.find({},
      sort: [
        ['amount', 'desc']
        ['priority', 'desc']
        ['time', 'desc']
      ]
    ).fetch()

  topSupporters: ->
    RS.Components.TopSupporters.topSupporters.find {},
      sort: [
        ['amount', 'desc']
        ['priority', 'desc']
        ['time', 'desc']
      ]

  transactionMessages: ->
    # Show all the transaction messages not already shown in the top 10 recent transactions.
    topRecentTransactionIds = _.map @topRecentTransactions(), '_id'

    RS.Components.TopSupporters.transactionMessages.find
      _id:
        $nin: topRecentTransactionIds
    ,
      sort:
        time: -1
