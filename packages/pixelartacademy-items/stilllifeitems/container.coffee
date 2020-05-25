LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Container extends PAA.Items.StillLifeItems
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Container'

  @translations: ->
    contentsSentence: "It contains:"

  @startingItemQuantities: ->
    # Override with a map of item IDs and quantities if the container has items initially.
    {}

  @withItems: ->
    items = @items()

    _.flatten [
      # Include the container that will appear at the location.
      @

      # Include all actual items.
      for item in items when itemClass = _.thingClass item.type
        itemClass.getCopyForId item.id
    ]

  constructor: ->
    super arguments...

    # Initialize starting items.
    @autorun (computation) =>
      return unless LOI.adventureInitialized()
      computation.stop()

      # Since we might add new starting items later, make sure all of them have been created.
      startingItemQuantities = @constructor.startingItemQuantities()
      createdItemQuantities = @state('createdItemQuantities') or {}
      currentItems = @constructor.items()

      createdItemQuantitiesUpdated = false

      for type, quantity of startingItemQuantities
        # Have we already made enough of these items?
        createdQuantity = createdItemQuantities[type] or 0
        continue if createdQuantity >= quantity

        # Determine how many we need to create. First subtract the amount we've already created.
        quantityLeft = quantity - createdQuantity

        # If there are any items already in the container, subtract those as well.
        existingItems = _.filter currentItems, (item) => item.type is type
        quantityLeft -= existingItems.length

        if quantityLeft > 0
          for i in [1..quantityLeft]
            @constructor.addItemOfType type

        # Update that we've created enough items of this type.
        createdItemQuantities[type] = quantity
        createdItemQuantitiesUpdated = true

      # If we've updated created item quantities, save them into the state.
      @state 'createdItemQuantities', createdItemQuantities
