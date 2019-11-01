LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.ShoppingCart.User extends HQ.Items.ShoppingCart
  onCreated: ->
    super arguments...

    # Get all store items data.
    @subscribe RS.Item.all

  cartItems: ->
    cartItems = []

    # Items in user's shopping cart come from the database as Retronator.Store.Items.
    for cartItem, index in @contents()
      item = RS.Item.documents.findOne catalogKey: cartItem.item
      continue unless item

      # Load bundle items as well.
      for bundleItem in item.items
        bundleItem.refresh()

      cartItems.push
        item: item
        isGift: cartItem.isGift
        cartIndex: index

    cartItems
