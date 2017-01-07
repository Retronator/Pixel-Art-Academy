AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Inventory extends AM.Component
  @register 'Retronator.Store.Pages.Inventory'

  onCreated: ->
    super

    @_itemsHandle = @subscribe 'Retronator.Accounts.Transactions.Item.all'

  items: ->
    user = Meteor.user()

    return unless @_itemsHandle.ready()

    # Return an array of items with all fields.
    items = _.map user.items, (item) -> RS.Transactions.Item.documents.findOne item._id

  events: ->
    super.concat
      'click .refresh-button': @clickRefreshButton
      
  clickRefreshButton: (event) ->
    Meteor.call 'Retronator.Accounts.User.generateItemsArrayForCurrentUser'
