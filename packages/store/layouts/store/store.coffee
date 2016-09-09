AM = Artificial.Mirage
RS = Retronator.Store

class RS.Layouts.Store extends BlazeLayoutComponent
  @register 'Retronator.Store.Layouts.Store'

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent

class RS.Layouts.Store.Header extends AM.Component
  @register 'Retronator.Store.Layouts.Store.Header'

  shoppingCart: ->
    RS.shoppingCart

  itemsCountText: ->
    count = RS.shoppingCart.items().length

    if count > 1 then "#{count} items" else "#{count} item"
