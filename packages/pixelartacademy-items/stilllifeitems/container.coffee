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

  @initialize: ->
    super arguments...

    startingItemQuantities = @startingItemQuantities()
    startingItems = []

    for type, quantity of startingItemQuantities
      for i in [1..quantity]
        startingItems.push
          id: Random.id()
          type: type

    # Override the items field with one that defaults to the starting items.
    @itemsField = @state.field 'items', default: startingItems

  @withItems: ->
    items = @items()

    _.flatten [
      # Include the container that will appear at the location.
      @

      # Include all actual items.
      for item in items when itemClass = _.thingClass item.type
        itemClass.getCopyForId item.id
    ]
