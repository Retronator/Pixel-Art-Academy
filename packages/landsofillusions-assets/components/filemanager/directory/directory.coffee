AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager.Directory extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.FileManager.Directory'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

    @selectedItems = new ReactiveField []

    @_previousSelectedItems = new ReactiveField []
    @_startRangeItem = new ReactiveField null

    @currentItems = new ComputedField =>
      documentSources = @options.fileManager.options.documents
      documentSources = [documentSources] unless _.isArray documentSources
  
      documents = for documentSource in documentSources
        documentSource.fetch {}
  
      _.sortBy _.flatten(documents), ['name', '_id']

    @width = new ReactiveField 100

  onCreated: ->
    super arguments...

  nameOrId: ->
    data = @currentData()

    data.name or "#{data._id.substring 0, 5}…"

  selectedClass: ->
    item = @currentData()

    'selected' if item in @selectedItems()

  iconUrl: ->
    item = @currentData()

    "/landsofillusions/assets/components/filemanager/#{_.toLower item.constructor.name}.png"

  directoryStyle: ->
    width: "#{@width()}rem"

  events: ->
    super(arguments...).concat
      'mousedown .divider': @onMouseDownDivider
      'contextmenu': @onContextMenu
      'click .item': @onClickItem

  onMouseDownDivider: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    $directory = @options.fileManager.$('.landsofillusions-assets-components-filemanager')

    # Remember starting position of drag.
    @_dragStart = event.pageX

    # Remember starting width.
    @_widthStart = @width()

    display = @callAncestorWith 'display'
    scale = display.scale()

    # Wire dragging handlers.
    $directory.on 'mousemove.landsofillusions-assets-components-filemanager-directory', (event) =>
      dragDelta = event.pageX - @_dragStart
      @width @_widthStart + dragDelta / scale

    $directory.on 'mouseup.landsofillusions-assets-components-filemanager-directory', (event) =>
      # End drag mode.
      $directory.off '.landsofillusions-assets-components-filemanager-directory'

  onContextMenu: (event) ->
    # Prevent normal context menu from opening.
    event.preventDefault()

    display = @callAncestorWith 'display'
    scale = display.scale()

    dialog =
      type: FM.Menu.Dropdown.id()
      left: event.pageX / scale
      top: event.pageY / scale
      canDismiss: true
      items: [
        LOI.Assets.Components.FileManager.Directory.NewFolder.id()
      ]

    @ancestorComponentOfType(FM.Interface).displayDialog dialog

  onClickItem: (event) ->
    item = @currentData()
    items = @currentItems()
    itemIndex = items.indexOf item

    selectedItems = @selectedItems()
    previousSelectedItems = @_previousSelectedItems()
    startRangeItem = @_startRangeItem()

    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown(AC.Keys.shift)
      # Update range selection.
      endRangeItem = item

    else if keyboardState.isCommandOrControlDown()
      # Add or remove the file from selection.

      if item in selectedItems
        # Remove the file from the selection
        if selectedItems.length is 1
          # We're removing the last item so we need to clear everything.
          previousSelectedItems = []
          startRangeItem = null
          endRangeItem = null

        else
          # Remove the clicked item and the last added one, which that will become the new range.
          _.pull selectedItems, item

          startRangeItem = _.last selectedItems
          _.pull selectedItems, startRangeItem

          endRangeItem = startRangeItem
          previousSelectedItems = selectedItems

      else
        # Add the file to the selection.
        previousSelectedItems = selectedItems
        startRangeItem = item
        endRangeItem = item

    else
      # Replace selection.
      previousSelectedItems = []
      startRangeItem = item
      endRangeItem = item

    if endRangeItem
      startRangeIndex = Math.max 0, items.indexOf startRangeItem
      endRangeIndex = items.indexOf endRangeItem

      # Make sure start index is smaller than the end one.
      [startRangeIndex, endRangeIndex] = [endRangeIndex, startRangeIndex] if startRangeIndex > endRangeIndex

      selectedItems = _.union previousSelectedItems, items[startRangeIndex..endRangeIndex]

    else
      selectedItems = previousSelectedItems

    @_startRangeItem startRangeItem
    @_previousSelectedItems previousSelectedItems
    @selectedItems selectedItems
