AT = Artificial.Telepathy
RA = Retronator.Accounts

class Retronator.Store
  constructor: ->
    @_addPage 'Retronator.Store', '/store', 'Retronator.Store.Pages.Store'
    @_addPage 'Retronator.Store.Cart', '/store/cart', 'Retronator.Store.Pages.Cart'
    @_addPage 'Retronator.Store.Checkout', '/store/checkout', 'Retronator.Store.Pages.Checkout'
    @_addPage 'Retronator.Store.Claim', '/store/claim/:keyCode?', 'Retronator.Store.Pages.Claim'
    @_addPage 'Retronator.Store.Money', '/store/money', 'Retronator.Store.Pages.Money'
    @_addPage 'Retronator.Store.Inventory', '/store/inventory', 'Retronator.Store.Pages.Inventory'
    @_addPage 'Retronator.Store.Account', '/store/account', 'Retronator.Store.Pages.Account'

  _addPage: (name, url, page) ->
    AT.addRoute name, url, 'Retronator.Store.Layouts.Store', page

# On the client, create the global shopping cart.
if Meteor.isClient
  Meteor.startup ->
    Retronator.Store.shoppingCart = new RA.Transactions.ShoppingCart
