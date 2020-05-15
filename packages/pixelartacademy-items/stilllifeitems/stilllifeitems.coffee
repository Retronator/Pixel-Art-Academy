LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems'
  @fullName: -> "still life items"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It's a collection of items that can be used when drawing still lives.
    "

  @translations: ->
    youCurrentlyHave: "You currently have:"

  @initialize()

  @items: ->
    items = @state('items') or []

    # Filter items to possible classes, in case we remove any of them at some point.
    _.filter items, (item) => _.thingClass item.type

  @itemsCount: ->
    items = @items()

    count = {}

    for item in items
      count[item.type] ?= 0
      count[item.type]++

    count

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
    # HACK: We get items directly from the state so the remove happens in place. If we use @items, for some reason the
    # state won't get updated with a new array that we send in time and immediate add actions for example will happen
    # on the old state, cached in the field.
    items = @state 'items'
    _.remove items, (item) => item.id is id

    @state 'items', items

  # Listener

  onCommand: (commandResponse) ->
    stillLifeItems = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.WhatIs], stillLifeItems]
      priority: 1
      action: =>
        LOI.adventure.showDescription stillLifeItems

        itemsCount = PAA.Items.StillLifeItems.itemsCount()
        listString = stillLifeItems.translations().youCurrentlyHave

        $list = $('<ul class="things">')

        for itemType, count of itemsCount
          item = LOI.adventure.getCurrentInventoryThing itemType

          $listItem = $('<li class="thing">')
          countString = if count > 1 then " x#{count}" else ""
          $listItem.append "#{_.upperFirst item.fullName()}#{countString}."

          $list.append $listItem

        LOI.adventure.interface.narrative.addText "#{listString}%%html#{$list[0].outerHTML}html%%"
