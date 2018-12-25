AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Components.FileManager'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

    @selectedItems = new ReactiveField []

    @_previousSelectedItems = new ReactiveField []
    @_startRangeItem = new ReactiveField null

    @currentItems = new ComputedField =>
      documentSources = @options.documents
      documentSources = [documentSources] unless _.isArray documentSources
  
      documents = for documentSource in documentSources
        documentSource.fetch {}
  
      _.sortBy _.flatten(documents), ['name', '_id']

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

  events: ->
    super(arguments...).concat
      'click .item': @onClickItem

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
