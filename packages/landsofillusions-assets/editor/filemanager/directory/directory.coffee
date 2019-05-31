AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager.Directory'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

    @_id = Random.id()

    @selectedItems = new ReactiveField []

  onCreated: ->
    super arguments...

    @_selectedNames = new ReactiveField []
    @_previousSelectedNames = new ReactiveField []
    @_startRangeName = new ReactiveField null
    @_endRangeName = new ReactiveField null

    @width = new ReactiveField 100

    @documents = new ComputedField =>
      documentSources = @options.fileManager.options.documents
      documentSources = [documentSources] unless _.isArray documentSources

      documents = for documentSource in documentSources
        if @options.path
          documentSource.fetch
            name: new RegExp "^#{@options.path}"

        else
          documentSource.fetch()

      _.flatten documents

    @newFolders = new ReactiveField []

    @currentItems = new ComputedField =>
      # Scan all documents and sort them into folders and files.
      folders = []
      files = []

      for document in @documents()
        unless document.name or @options.path
          # We're in the root folder and the document doesn't have a path, so we should display the item here.
          document.sortingName = _.toLower document._id
          files.push document
          continue

        nameParts = LOI.Assets.Editor.FileManager.itemNameParts document, @options.path

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

      actuallyNewFolders = _.filter @newFolders(), (folder) =>
        not _.find folders, (existingFolder) => folder.name is existingFolder.name

      folders.push actuallyNewFolders...

      items = folders.concat files

      # Update selected items when current items change.
      selectedNames = @_selectedNames()
      newSelectedNames = _.filter items, (item) => (item.name or item._id) in selectedNames
      @selectedItems newSelectedNames

      _.sortBy items, 'sortingName'

    @editingNameItem = new ReactiveField null

    @draggingOverDirectoryCount = new ReactiveField 0
    @draggingOverFolder = new ReactiveField null
    @draggingOverFolderCount = new ReactiveField 0

  onRendered: ->
    super arguments...

    $(document).on "keydown.landsofillusions-assets-editor-filemanager-directory-#{@_id}", (event) => @onKeyDown event

  onDestroyed: ->
    super arguments...

    $(document).off ".landsofillusions-assets-editor-filemanager-directory-#{@_id}"

  selectItem: (name) ->
    @_changeSelection [], name, name

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
    item = @currentData()

    if item.name
      nameParts = LOI.Assets.Editor.FileManager.itemNameParts item
      nameParts.filename

    else
      item._id

  selectedClass: ->
    item = @currentData()

    'selected' if item in @selectedItems()

  typeClass: ->
    item = @currentData()

    _.toLower item.constructor.name

  iconUrl: ->
    item = @currentData()
    iconName = item.iconName?() or _.toLower item.constructor.name

    "/landsofillusions/assets/components/filemanager/#{iconName}.png"

  directoryStyle: ->
    width: "#{@width()}rem"

  editingName: ->
    item = @currentData()
    item is @editingNameItem()

  directoryDropTargetClass: ->
    'drop-target' if @draggingOverFolderCount() is 0 and @draggingOverDirectoryCount() > 0

  itemDropTargetClass: ->
    item = @currentData()
    'drop-target' if item is @draggingOverFolder() and @draggingOverFolderCount() > 0

  draggableAttribute: ->
    draggable: true unless @editingName()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'mousedown .divider': @onMouseDownDivider
      'contextmenu': @onContextMenu
      'click .item': @onClickItem
      'dragstart .item': @onDragStartItem
      'dragenter .folder': @onDragEnterFolder
      'dragover .folder': @onDragOverFolder
      'dragleave .folder': @onDragLeaveFolder
      'drop .folder': @onDropFolder
      'dragenter .items': @onDragEnterDirectory
      'dragover .items': @onDragOverDirectory
      'dragleave .items': @onDragLeaveDirectory
      'drop .items, .drop .item': @onDropDirectory
      'click .name': @onClickName
      'change .name-input, blur .name-input': @onChangeNameInput

  onClick: (event) ->
    @options.fileManager.focusDirectory @

  onMouseDownDivider: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    # Remember starting position of drag.
    @_dragStart = event.pageX

    # Remember starting width.
    @_widthStart = @width()

    display = @callAncestorWith 'display'
    scale = display.scale()

    # Wire dragging handlers.
    $document = $(document)

    $document.on 'mousemove.landsofillusions-assets-editor-filemanager-directory', (event) =>
      dragDelta = event.pageX - @_dragStart
      @width @_widthStart + dragDelta / scale

    $document.on 'mouseup.landsofillusions-assets-editor-filemanager-directory', (event) =>
      # End drag mode.
      $document.off '.landsofillusions-assets-editor-filemanager-directory'

  onContextMenu: (event) ->
    # Context menu works only when we're inside FataMorgana UI.
    return unless userInterface = @ancestorComponentOfType FM.Interface

    # Prevent normal context menu from opening.
    event.preventDefault()

    @options.fileManager.focusDirectory @

    display = @callAncestorWith 'display'
    scale = display.scale()

    dropdownItems = []

    selectedItems = @selectedItems()
    selectedItem = @selectedItems()?[0]

    if selectedItems.length is 1 and selectedItem instanceof LOI.Assets.Editor.FileManager.Directory.Folder and selectedItem.name is 'trash'
      dropdownItems.push LOI.Assets.Editor.FileManager.Directory.EmptyTrash.id()

    else
      dropdownItems.push LOI.Assets.Editor.FileManager.Directory.NewFolder.id()

      if selectedItems.length
        dropdownItems.push LOI.Assets.Editor.FileManager.Directory.CreateRot8.id()
        dropdownItems.push LOI.Assets.Editor.FileManager.Directory.Duplicate.id()

        unless _.startsWith selectedItem.name, 'trash/'
          dropdownItems.push LOI.Assets.Editor.FileManager.Directory.Delete.id()

    dialog =
      directory: @
      type: FM.Menu.Dropdown.id()
      left: event.pageX / scale
      top: event.pageY / scale
      canDismiss: true
      items: dropdownItems

    userInterface.displayDialog dialog

  onClickItem: (event) ->
    return if @editingNameItem()

    item = @currentData()
    @_changeEndRange item.name or item._id

  _changeEndRange: (endRangeName) ->
    selectedNames = @_selectedNames()
    keyboardState = AC.Keyboard.getState()

    if @options.fileManager.options.multipleSelect and keyboardState.isKeyDown(AC.Keys.shift)
      # Update range selection.
      @_changeSelection @_previousSelectedNames(), @_startRangeName(), endRangeName

    else if @options.fileManager.options.multipleSelect and keyboardState.isCommandOrControlDown()
      # Add or remove the file from selection.
      if endRangeName in selectedNames
        # Remove the file from the selection
        if selectedNames.length is 1
          # We're removing the last item so we need to clear everything.
          @_changeSelection [], null, null

        else
          # Remove the clicked item and the last added one, which that will become the new range.
          _.pull selectedNames, endRangeName

          lastName = _.last selectedNames
          _.pull selectedNames, lastName

          @_changeSelection selectedNames, lastName, lastName

      else
        # Add the file to the selection.
        @_changeSelection selectedNames, endRangeName, endRangeName

    else
      if endRangeName in selectedNames
        switch event.detail
          when 1
            # This is the first click. Replace selection after a timeout, in case a double click is being performed.
            @_clickItemTimeout = Meteor.setTimeout =>
              @_changeSelection [], endRangeName, endRangeName
            ,
              500

            # We should also not cancel the renaming timeout that
            # started if this was a click on the name inside the item.
            doNotCancelRenaming = true

          when 2
            # This is a double click. Cancel change of selection and perform default operation.
            Meteor.clearTimeout @_clickItemTimeout
            @options.fileManager.options.defaultOperation?()

      else
        # Replace selection.
        @_changeSelection [], endRangeName, endRangeName

    Meteor.clearTimeout @_startRenamingItemTimeout unless doNotCancelRenaming

  _changeSelection: (previousSelectedNames, startRangeName, endRangeName) ->
    items = @currentItems()

    if endRangeName
      startRangeIndex = Math.max 0, _.findIndex items, (item) => (item.name or item._id) is startRangeName
      endRangeIndex = _.findIndex items, (item) => (item.name or item._id) is endRangeName

      # Make sure start index is smaller than the end one.
      [startRangeIndex, endRangeIndex] = [endRangeIndex, startRangeIndex] if startRangeIndex > endRangeIndex

      selectedNames = _.union previousSelectedNames, (item.name or item._id for item in items[startRangeIndex..endRangeIndex])

    else
      selectedNames = previousSelectedNames

    @_startRangeName startRangeName
    @_endRangeName endRangeName
    @_previousSelectedNames previousSelectedNames
    @_selectedNames selectedNames

    selectedItems = _.filter items, (item) => (item.name or item._id) in selectedNames
    @selectedItems selectedItems

  onDragStartItem: (event) ->
    item = @currentData()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    # See if we're dragging one of the selected files or another one.
    selectedItems = @selectedItems()

    if item in selectedItems
      draggedItems = selectedItems

    else
      draggedItems = [item]

    @options.fileManager.startDrag draggedItems

  onDragEnterFolder: (event) ->
    folder = @currentData()
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    if folder is @draggingOverFolder()
      @draggingOverFolderCount @draggingOverFolderCount() + 1

    else
      @draggingOverFolder folder
      @draggingOverFolderCount 1

  onDragOverFolder: (event) ->
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

  onDragLeaveFolder: (event) ->
    # Make sure we're leaving the active folder.
    folder = @currentData()
    return unless folder is @draggingOverFolder()

    event.preventDefault()

    @draggingOverFolderCount Math.max 0, @draggingOverFolderCount() - 1

  onDropFolder: (event) ->
    folder = @currentData()
    event.preventDefault()

    @options.fileManager.endDrag folder

    @draggingOverFolderCount 0
    @draggingOverDirectoryCount 0

  onDragEnterDirectory: (event) ->
    # Only allow dragging onto a directory that's not the source of the dragged items.
    return if @options.fileManager.draggedItems()?[0] in @currentItems()

    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    @draggingOverDirectoryCount @draggingOverDirectoryCount() + 1

  onDragOverDirectory: (event) ->
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

  onDragLeaveDirectory: (event) ->
    event.preventDefault()

    @draggingOverDirectoryCount Math.max 0, @draggingOverDirectoryCount() - 1

  onDropDirectory: (event) ->
    # Make sure we're dragging over the directory.
    return if @draggingOverDirectoryCount() is 0

    # Only handle dropping onto the whole directory if we're not hovering over a folder.
    return if @draggingOverFolderCount() > 0

    event.preventDefault()

    # Remove trailing slash from the path.
    folderName = _.trimEnd @options.path, '/'
    folder = new @constructor.Folder folderName

    @options.fileManager.endDrag folder
    @draggingOverDirectoryCount 0

  onClickName: (event) ->
    item = @currentData()

    # We can only rename an item if it's the only selected items.
    selectedItems = @selectedItems()
    return unless selectedItems.length is 1 and item in selectedItems

    # Start renaming after a delay to properly handle double clicks on items.
    Meteor.clearTimeout @_startRenamingItemTimeout

    @_startRenamingItemTimeout = Meteor.setTimeout =>
      @startRenamingItem item
    ,
      500

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
        for document in @documents() when _.startsWith document.name, item.name
          newDocumentName = document.name.replace item.name, newName
          assetClassName = document.constructor.name

          LOI.Assets.Asset.update assetClassName, document._id,
            $set:
              name: newDocumentName

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
          $set:
            name: newName

    @editingNameItem null
    @_selectedNames [newName]

    $input.closest('.entry').scrollLeft 0

  onKeyDown: (event) ->
    # Directory needs to be focused to react to key events.
    return unless @options.fileManager.focusedDirectory() is @

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
          endRangeName = @_endRangeName()
          endRangeIndex = _.findIndex items, (item) => (item.name or item._id) is endRangeName

          if event.which is AC.Keys.down
            endRangeIndex = Math.min items.length - 1, endRangeIndex + 1

          else
            endRangeIndex = Math.max 0, endRangeIndex - 1

          newItem = items[endRangeIndex]
          @_changeEndRange newItem.name or newItem._id

          # Do not scroll by default.
          event.preventDefault()

        when AC.Keys.left
          directories = @options.fileManager.directories()
          directoryIndex = directories.indexOf @

          return unless directoryIndex > 0

          # Clear selection in this directory.
          @_changeSelection [], null, null

          # Focus on previous directory.
          @options.fileManager.focusDirectory directories[directoryIndex - 1]

          # Do not let the newly focused directory also handle the event.
          event.stopImmediatePropagation()

          # Do not scroll by default.
          event.preventDefault()

        when AC.Keys.right
          # Make sure we're on a folder.
          selectedItems = @selectedItems()
          return unless selectedItems.length is 1 and selectedItems[0] instanceof @constructor.Folder

          # Focus on next directory.
          directories = @options.fileManager.directories()
          directoryIndex = directories.indexOf @
          newDirectory = directories[directoryIndex + 1]
          @options.fileManager.focusDirectory newDirectory

          # Do not let the newly focused directory also handle the event.
          event.stopImmediatePropagation()

          # Select first item in the new directory.
          item = newDirectory.currentItems()[0]
          newDirectory._changeSelection [], item?.name, item?.name

          # Do not scroll by default.
          event.preventDefault()

          # Scroll to right.
          $directories = @$('.landsofillusions-assets-editor-filemanager-directory').closest('.directories')
          $directories.scrollLeft 1e8

        when AC.Keys.return
          if @options.fileManager.options.defaultOperation
            @options.fileManager.options.defaultOperation()

          else
            @startRenamingItem selectedItems[0]
