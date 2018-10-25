AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Counter extends LOI.Adventure.Context
  @id: -> 'Retronator.HQ.Store.Counter'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @illustrationHeight: -> 240

  @initialize()

  constructor: ->
    super arguments...

    @smiling = new ReactiveField false

    @showReceiptSupporters = new ReactiveField false

  onCreated: ->
    super arguments...

    @subscribe RS.Transaction.topRecent, 15
    @subscribe RA.User.topSupportersCurrentUser

    @_topSupportersCount = new ReactiveField 10

    @autorun (computation) =>
      @subscribe RA.User.topSupporters, @_topSupportersCount()

    @_messagesCount = new ReactiveField 50

    @autorun (computation) =>
      @subscribe RS.Transaction.messages, @_messagesCount()

  onRendered: ->
    super arguments...

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

    @$scene = @$('.scene')
    @$display = @$('.display')
    @$retro = @$('.retro')
    @$retroShadow = @$('.retro-shadow')
    @$table = @$('.table')

  sceneStyle: ->
    viewport = LOI.adventure.interface.display.viewport()

    left: viewport.safeArea.left()

  smile: ->
    @smiling true

    Meteor.setTimeout =>
      @smiling false
    ,
      5500

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

  events: ->
    super(arguments...).concat
      'click .top-supporters .show-more-button': @onClickTopSupportersShowMoreButton

  onClickTopSupportersShowMoreButton: (event) ->
    @_topSupportersCount @_topSupportersCount() + 40

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @$scene.css transform: "translate3d(0, #{-scrollTop}px, 0)"

    @$table.css transform: "translate3d(0, #{scrollTop * 15 / 120}px, 0)"
    @$retro.css transform: "translate3d(0, #{scrollTop * 20 / 120}px, 0)"
    @$retroShadow.css transform: "translate3d(0, #{scrollTop * 40 / 120}px, 0)"
    @$display.css transform: "translate3d(0, #{scrollTop * 40 / 120}px, 0)"
