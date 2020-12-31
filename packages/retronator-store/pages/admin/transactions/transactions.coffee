AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Transactions extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Transactions'
  @register @id()

  @giveItem: new AB.Method name: "#{@id()}.giveItem"
  @transactionsForUserIdOrEmailOrTwitter: new AB.Subscription
    name: "#{@id()}.transactionsForUserIdOrEmailOrTwitterHandle"
    query: (userId, email, twitter) =>
      query = $or: []

      if userId
        query.$or.push
          'user._id': userId

      if email
        query.$or.push
          email: new RegExp email, 'i'

      if twitter
        query.$or.push
          twitter: new RegExp twitter, 'i'

      return unless query.$or.length

      RS.Transaction.documents.find query,
        sort:
          time: -1

  onCreated: ->
    super arguments...

    RS.Item.all.subscribe @

    @userId = new ReactiveField null
    @email = new ReactiveField null
    @twitter = new ReactiveField null

    @autorun (computation) =>
      @constructor.transactionsForUserIdOrEmailOrTwitter.subscribe @userId(), @email(), @twitter()

  transactions: ->
    @constructor.transactionsForUserIdOrEmailOrTwitter.query @userId(), @email(), @twitter()

  itemCatalogKeys: ->
    items = RS.Item.documents.fetch {}, sort: catalogKey: 1

    _.map items, 'catalogKey'

  events: ->
    super(arguments...).concat
      'click .give-item-button': @onClickGiveItemButton

  onClickGiveItemButton: (event) ->
    catalogKey = @$('.give-item-catalog-key-select').val()
    @constructor.giveItem @userId(), @email(), @twitter(), catalogKey

  class @IdentificationInput extends AM.DataInputComponent
    onCreated: ->
      @transactionsComponent = @ancestorComponentOfType RS.Pages.Admin.Transactions

    load: ->
      @transactionsComponent[@field()]()

    save: (value) ->
      @transactionsComponent[@field()] value

  class @UserID extends @IdentificationInput
    @register 'Retronator.Store.Pages.Admin.Transactions.UserId'
    field: -> 'userId'

  class @Email extends @IdentificationInput
    @register 'Retronator.Store.Pages.Admin.Transactions.Email'
    field: -> 'email'

  class @Twitter extends @IdentificationInput
    @register 'Retronator.Store.Pages.Admin.Transactions.Twitter'
    field: -> 'twitter'
