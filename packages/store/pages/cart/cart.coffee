AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Cart extends AM.Component
  @register 'Retronator.Store.Pages.Cart'
  
  onCreated: ->
    super

    # Get all store items data.
    @subscribe 'Retronator.Accounts.Transactions.Item.all'

  shoppingCart: ->
    RS.shoppingCart

  giftCheckboxAttributes: ->
    item = @currentData()

    checked: true if item.isGift

  events: ->
    super.concat
      'click .remove-from-cart-button': @onClickRemoveFromCartButton
      'change .gift-checkbox': @onChangeGiftCheckbox

  onClickRemoveFromCartButton: (event) ->
    item = @currentData()

    RS.shoppingCart.removeItem item

  onChangeGiftCheckbox: (event) ->
    item = @currentData()
    RS.shoppingCart.setItemIsGift item, event.target.checked
