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

  startDrag: (itemId) ->
    @draggedItemIndex _.findIndex @items(), (item) => item.id is itemId
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
    #_.pull items, draggedItem

    # Reset dragging fields to stop reordering.
    @draggedItemId null
    @draggedItemIndex null

    # Update items to the new order.
    PAA.Items.StillLifeItems.setItems items

    # Add the dragged item to stand.
    @stillLifeStand.addDraggedItem draggedItem

    # Do not listen to end drag any more.
    $(document).off 'mouseup.pixelartacademy-stilllifestand-inventory'

  cursorClass: ->
    return 'grabbing' if @draggedItemId()

    null

  events: ->
    super(arguments...).concat
      'mousedown .item': @onMouseDownItem
      'mouseenter .item': @onMouseEnterItem
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

  onMouseLeaveInventory: (event) ->
    return unless @draggedItemId()

    @dragToStand()
