LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems'
  @fullName: -> "still life items"
  @description: ->
    "
      It's a collection of items that can be used when drawing still lives.
    "

  @initialize()

  @items: ->
    @state('items') or []

  @setItems: (items) ->
    items = _.without items, null, undefined

    @state 'items', items

  @addItem: (id, type) ->
    items = @items()
    items.push {id, type}

    @state 'items', items

  @addItemOfType: (type) ->
    id = Random.id()
    @addItem id, type

  @removeItemForId: (id) ->
    items = @items()
    _.remove items, (item) => item.id is id

    @state 'items', items
