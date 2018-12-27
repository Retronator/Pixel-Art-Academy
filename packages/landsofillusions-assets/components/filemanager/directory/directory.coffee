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

  onCreated: ->
    super arguments...

    @selectedItems = new ReactiveField []

    @_selectedNames = new ReactiveField []
    @_previousSelectedNames = new ReactiveField []
    @_startRangeName = new ReactiveField null

    @width = new ReactiveField 100

    @documents = new ComputedField =>
      documentSources = @options.fileManager.options.documents
      documentSources = [documentSources] unless _.isArray documentSources

      documents = for documentSource in documentSources
        documentSource.fetch
          name: new RegExp "^#{@options.path}"

      _.flatten documents

    @newFolders = new ReactiveField []

    @currentItems = new ComputedField =>
      # Scan all documents and sort them into folders and files.
      folders = []
      files = []

      for document in @documents() when document.name
        nameParts = @_nameParts document
        if firstFolder = nameParts.folders[0]
          # This is a file deeper inside the folder so just see if we need to add the folder.
          folders.push firstFolder unless firstFolder in folders

        else
          # This is a file at top level of the path.
          document.sortingName = _.toLower nameParts.filename
          files.push document

      # Create full folder objects.
      folders = for folder in folders
        new @constructor.Folder "#{@options.path}#{folder}", _.toLower folder

      folders.push @newFolders()...

      items = folders.concat files

      # Update selected items when current items change.
      selectedNames = @_selectedNames()
      @selectedItems _.filter items, (item) => item.name in selectedNames

      _.sortBy items, 'sortingName'

    @editingNameItem = new ReactiveField null

  onRendered: ->
    super arguments...

    $(document).on 'keydown.landsofillusions-assets-components-filemanager-directory', (event) => @onKeyDown event

  onDestroyed: ->
    super arguments...

    $(document).off '.landsofillusions-assets-components-filemanager-directory'

  _nameParts: (item) ->
    name = item.name.substring @options.path.length
    nameParts = name.split '/'

    # Last part is always the filename, the rest is the path.
    filename = _.last nameParts
    folders = _.initial nameParts

    path = folders.join '/'

    {path, folders, filename}

  newFolder: ->
    newFolderName = "untitled folder"
    newFolder = new @constructor.Folder "#{@options.path}#{newFolderName}", newFolderName

    newFolders = @newFolders()
    newFolders.push newFolder
    @newFolders newFolders

    @startRenamingItem newFolder, true

  startRenamingItem: (item, selectAll) ->
    @editingNameItem item

    Tracker.afterFlush =>
      $nameInput = @$('.name-input')
      $nameInput.focus()
      $nameInput.select() if selectAll

  nameOrId: ->
    data = @currentData()

    data.name or "#{data._id.substring 0, 5}…"

  selectedClass: ->
    item = @currentData()

    'selected' if item in @selectedItems()

  typeClass: ->
    item = @currentData()

    _.toLower item.constructor.name

  iconUrl: ->
    item = @currentData()

    "/landsofillusions/assets/components/filemanager/#{_.toLower item.constructor.name}.png"

  directoryStyle: ->
    width: "#{@width()}rem"

  editingName: ->
    item = @currentData()
    item is @editingNameItem()

  events: ->
    super(arguments...).concat
      'mousedown .divider': @onMouseDownDivider
      'contextmenu': @onContextMenu
      'click .item': @onClickItem
      'click .name': @onClickName
      'change .name-input, blur .name-input': @onChangeNameInput

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
      directory: @
      type: FM.Menu.Dropdown.id()
      left: event.pageX / scale
      top: event.pageY / scale
      canDismiss: true
      items: [
        LOI.Assets.Components.FileManager.Directory.NewFolder.id()
      ]

    @ancestorComponentOfType(FM.Interface).displayDialog dialog

  onClickItem: (event) ->
    return if @editingNameItem()

    item = @currentData()
    items = @currentItems()

    selectedNames = @_selectedNames()
    previousSelectedNames = @_previousSelectedNames()
    startRangeName = @_startRangeName()

    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown(AC.Keys.shift)
      # Update range selection.
      endRangeName = item.name

    else if keyboardState.isCommandOrControlDown()
      # Add or remove the file from selection.

      if item.name in selectedNames
        # Remove the file from the selection
        if selectedNames.length is 1
          # We're removing the last item so we need to clear everything.
          previousSelectedNames = []
          startRangeName = null
          endRangeName = null

        else
          # Remove the clicked item and the last added one, which that will become the new range.
          _.pull selectedNames, item.name

          startRangeName = _.last selectedNames
          _.pull selectedNames, startRangeName

          endRangeName = startRangeName
          previousSelectedNames = selectedNames

      else
        # Add the file to the selection.
        previousSelectedNames = selectedNames
        startRangeName = item.name
        endRangeName = item.name

    else
      # Replace selection.
      previousSelectedNames = []
      startRangeName = item.name
      endRangeName = item.name

    if endRangeName
      startRangeIndex = Math.max 0, _.findIndex items, (item) => item.name is startRangeName
      endRangeIndex = _.findIndex items, (item) => item.name is endRangeName

      # Make sure start index is smaller than the end one.
      [startRangeIndex, endRangeIndex] = [endRangeIndex, startRangeIndex] if startRangeIndex > endRangeIndex

      selectedNames = _.union previousSelectedNames, (item.name for item in items[startRangeIndex..endRangeIndex])

    else
      selectedNames = previousSelectedNames

    @_startRangeName startRangeName
    @_previousSelectedNames previousSelectedNames
    @_selectedNames selectedNames

    selectedItems = _.filter items, (item) => item.name in selectedNames
    @selectedItems selectedItems

  onClickName: (event) ->
    item = @currentData()

    # We can only rename an item if it's the only selected items.
    selectedItems = @selectedItems()
    return unless selectedItems.length is 1 and item in selectedItems

    @startRenamingItem item

  onChangeNameInput: (event) ->
    # Make sure the input is still relevant.
    return unless item = @editingNameItem()

    $input = $(event.target)
    newFilename = $input.val()
    newName = "#{@options.path}#{newFilename}"

    # Make sure this is a new name.
    if newName.length and newName isnt item.name
      if item instanceof @constructor.Folder
        # Rename all documents with this folder's path.

        # Rename the new folder.
        newFolders = @newFolders()

        if item in newFolders
          item.name = newName
          item.sortingName = _.toLower newFilename
          @newFolders newFolders

      else
        # Rename the document.
        assetClassName = item.constructor.name
        LOI.Assets.Asset.update assetClassName, item._id,
          name: newName

    @editingNameItem null
    @_selectedNames [newName]

    $input.closest('.entry').scrollLeft 0

  onKeyDown: (event) ->
    # Only react if we have a selection or we're editing a name.
    selectedItems = @selectedItems()
    return unless selectedItems.length

    if @editingNameItem()
      switch event.which
        when AC.Keys.return
          @$('.name-input').blur()

    else
      items = @currentItems()

      switch event.which
        when AC.Keys.down, AC.Keys.up
          targetItem = _.last selectedItems
          targetItemIndex = items.indexOf(targetItem)

          if event.which is AC.Keys.down
            newItemIndex = Math.min items.length - 1, targetItemIndex + 1

          else
            newItemIndex = Math.max 0, targetItemIndex - 1

          newItem = items[newItemIndex]
          @_startRangeName newItem.name
          @_previousSelectedNames []
          @_selectedNames [newItem.name]
          @selectedItems [newItem]

          # Do not scroll by default.
          event.preventDefault()

        when AC.Keys.return
          if selectedItems.length is 1
            @startRenamingItem selectedItems[0]
