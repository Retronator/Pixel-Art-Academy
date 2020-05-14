AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Inventory extends AM.Component
  @id: -> 'PixelArtAcademy.StillLifeStand.Inventory'
  @register @id()

  constructor: (@stillLifeStand) ->
    super arguments...

  onCreated: ->
    super arguments...

    @draggedItemId = new ReactiveField null
    @draggedItemIndex = new ReactiveField null

  items: ->
    # Add _id field to reduce recomputation.
    items = for item in PAA.Items.StillLifeItems.items()
      _.extend
        _id: item.id
      ,
        item

    if draggedItemId = @draggedItemId()
      # Remove the dragged item.
      draggedItem = _.find items, (item) => item.id is draggedItemId
      _.pull items, draggedItem

      # Insert it in the new position.
      draggedItemIndex = @draggedItemIndex()
      items.splice draggedItemIndex, 0, draggedItem

    items

  startDrag: (itemId, startingIndex) ->
    # Automatically calculate starting index if it's not provided.
    startingIndex ?= _.findIndex @items(), (item) => item.id is itemId
    @draggedItemIndex startingIndex

    @draggedItemId itemId

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-stilllifestand-inventory', =>
      $(document).off 'mouseup.pixelartacademy-stilllifestand-inventory'

      @endDrag()

  endDrag: ->
    items = PAA.Items.StillLifeItems.items()
    draggedItemId = @draggedItemId()
    draggedItemIndex = @draggedItemIndex()

    # Remove the dragged item.
    draggedItem = _.find items, (item) => item.id is draggedItemId
    _.pull items, draggedItem

    # Insert it in the new position.
    draggedItemIndex = @draggedItemIndex()
    items.splice draggedItemIndex, 0, draggedItem

    # Reset dragging fields to stop reordering.
    @draggedItemId null
    @draggedItemIndex null

    # Update items to the new order.
    PAA.Items.StillLifeItems.setItems items

  dragToStand: ->
    items = PAA.Items.StillLifeItems.items()
    draggedItemId = @draggedItemId()

    # Remove the dragged item.
    draggedItem = _.find items, (item) => item.id is draggedItemId
    _.pull items, draggedItem

    # Reset dragging fields to stop reordering.
    @draggedItemId null
    @draggedItemIndex null

    # Update items to the new order.
    PAA.Items.StillLifeItems.setItems items

    # Add the dragged item to stand.
    @stillLifeStand.addDraggedItem draggedItem

    # Do not listen to end drag any more.
    $(document).off 'mouseup.pixelartacademy-stilllifestand-inventory'

  dragFromStandToIndex: (index) ->
    newItem = @stillLifeStand.movingItem()
    items = PAA.Items.StillLifeItems.items()

    # Make sure this item hasn't been added yet.
    existingItem = _.find items, (item) => item.id is newItem._id

    return if existingItem

    # Add the relevant item data to the stand.
    PAA.Items.StillLifeItems.addItem newItem._id, newItem.id()

    # Start dragging it once it's added.
    @autorun (computation) =>
      items = PAA.Items.StillLifeItems.items()
      addedItem = _.find items, (item) => item.id is newItem._id

      return unless addedItem
      computation.stop()

      @startDrag addedItem.id, index

      # Remove the item from the stand.
      @stillLifeStand.removeMovingItem()

  cursorClass: ->
    return 'grabbing' if @draggedItemId()

    null

  events: ->
    super(arguments...).concat
      'mousedown .item': @onMouseDownItem
      'mouseenter .item': @onMouseEnterItem
      'mouseenter .pixelartacademy-stilllifestand-inventory': @onMouseEnterInventory
      'mouseleave .pixelartacademy-stilllifestand-inventory': @onMouseLeaveInventory

  onMouseDownItem: (event) ->
    draggedItem = @currentData()

    # Prevent browser select/dragging behavior.
    event.preventDefault()

    @startDrag draggedItem.id

  onMouseEnterItem: (event) ->
    return unless draggedItemId = @draggedItemId()

    enteredItem = @currentData()

    # Nothing to do when entering the dragged item.
    return if enteredItem.id is draggedItemId

    enteredItemIndex = _.findIndex @items(), (item) => item.id is enteredItem.id
    draggedItemIndex = @draggedItemIndex()

    if enteredItemIndex < draggedItemIndex
      # We're dragging left before the entered item. Push it in its place.
      @draggedItemIndex enteredItemIndex

    else
      # We're dragging right after the entered item. Push it after its place.
      @draggedItemIndex enteredItemIndex + 1

  onMouseEnterInventory: (event) ->
    return unless @stillLifeStand.movingItem()

    # Find out where to place the new item.
    mouse = event.clientX

    itemCenters = for item in @$('.item')
      $item = $(item)
      $item.offset().left + $item.width() / 2

    newItemIndex = 0
    newItemIndex++ while (newItemIndex < itemCenters.length and mouse > itemCenters[newItemIndex])

    @dragFromStandToIndex newItemIndex

  onMouseLeaveInventory: (event) ->
    return unless @draggedItemId()

    @dragToStand()
