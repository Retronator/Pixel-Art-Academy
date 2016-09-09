RA = Retronator.Accounts

FlowRouter.wait()

class Retronator.Store extends Artificial.Base.App
  @register 'Retronator.Store'

  @shoppingCart: new RA.Transactions.ShoppingCart

  constructor: ->
    super

    @_addPage 'store', '/', 'Retronator.Store.Pages.Store'
    @_addPage 'cart', '/cart', 'Retronator.Store.Pages.Cart'
    @_addPage 'checkout', '/checkout', 'Retronator.Store.Pages.Checkout'
    @_addPage 'claim', '/claim/:keyCode?', 'Retronator.Store.Pages.Claim'
    @_addPage 'money', '/money', 'Retronator.Store.Pages.Money'
    @_addPage 'inventory', '/inventory', 'Retronator.Store.Pages.Inventory'
    @_addPage 'account', '/account', 'Retronator.Store.Pages.Account'

    FlowRouter.initialize()

  _addPage: (name, url, page) ->
    @_addRoute name, url, 'Retronator.Store.Layouts.Store', page

  _addRoute: (name, url, layout, page) ->
    FlowRouter.route url,
      name: name
      action: (params, queryParams) ->
        BlazeLayout.render layout,
          page: page
