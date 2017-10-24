AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Store extends AM.Component
  @register 'Retronator.Store.Pages.Store'
  
  onCreated: ->
    super

    # Get all store items data.
    @subscribe 'Retronator.Accounts.Transactions.Item.all'

    # Get all user's transactions and payments so we can determine which store items they are
    # eligible for. Payments are needed to determine if the user has a kickstarter pledge.
    @subscribe 'Retronator.Accounts.Transactions.Transaction.forCurrentUser'
    @subscribe 'Retronator.Accounts.Transactions.Payment.forCurrentUser'

  shoppingCart: ->
    RS.shoppingCart

  storeItems: ->
    items = RS.Item.documents.find
      price:
        $exists: true
    ,
      sort:
        price: 1

    # Show only items that the user is eligible to purchase.
    items = _.filter items.fetch(), (item) =>
      # We need to perform validation with inherited child's code, so first do a cast.
      item = item.cast()

      try
        item.validateEligibility()

      catch error
        return false

      true

    # Refresh all the items to populate bundle sub-items.
    item.refresh() for item in items

    items

  events: ->
    super.concat
      'click .add-to-cart-button': @onClickAddToCartButton

  onClickAddToCartButton: (event) ->
    item = @currentData()
    
    RS.shoppingCart.addItem item
      
    FlowRouter.go 'Retronator.Store.Cart'
