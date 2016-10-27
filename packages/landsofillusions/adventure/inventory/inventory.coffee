AB = Artificial.Babel
LOI = LandsOfIllusions

# The inventory holds items and also acts as a map from item ID -> item instance.
class LOI.Adventure.Inventory
  constructor: (@options) ->
    @adventure = @options.adventure

    @items = new ReactiveField []

  addItem: (item) ->
    @items @items().concat item
    @[item.id()] = item

  removeItem: (item) ->
    items = @items()

    itemIndex = items.indexOf item
    return unless itemIndex > -1

    items.splice itemIndex, 1

    @items items

    @[item.id()] = null
