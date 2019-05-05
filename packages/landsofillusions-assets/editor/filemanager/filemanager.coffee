AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager'
  @register @id()

  @itemNameParts: (item, rootPath = '') ->
    # If we have no name, the file is assumed to be in the root folder.
    return path: '', folders: [], filename: '' unless item.name

    name = item.name.substring rootPath.length
    nameParts = name.split '/'

    # Last part is always the filename, the rest is the path.
    filename = _.last nameParts
    folders = _.initial nameParts

    path = folders.join '/'

    {path, folders, filename}

  constructor: (@options) ->
    super arguments...

    @options.multipleSelect ?= true

  onCreated: ->
    super arguments...

    rootDirectory = new @constructor.Directory
      fileManager: @
      path: ''

    @_directories = [rootDirectory]

    @directories = new ComputedField =>
      newDirectories = [rootDirectory]

      # Create a stack of directories based on selected folders.
      for directory, index in @_directories
        selectedItems = directory.selectedItems()
        break unless selectedItems.length is 1 and selectedItems[0] instanceof @constructor.Directory.Folder

        folder = selectedItems[0]

        # See if the next directory is present in our current stack.
        nextDirectoryPath = "#{folder.name}/"

        if @_directories[index + 1]?.options.path is nextDirectoryPath
          newDirectories.push @_directories[index + 1]

        else
          # We need to create the new directory.
          newDirectory = new @constructor.Directory
            fileManager: @
            path: nextDirectoryPath

          newDirectories.push newDirectory

          # Register dependency on new directory's selected items.
          newDirectory.selectedItems()

          # The new directory will always be at the end of the stack.
          break

      @_directories = newDirectories
      @_directories

    @draggedItems = new ReactiveField null
    
    @focusedDirectory = new ReactiveField null

    @selectedItems = new ComputedField =>
      lastDirectory = _.last @directories()
      lastDirectory.selectedItems()

    @selectedItem = new ComputedField =>
      selectedItems = @selectedItems()

      if selectedItems.length is 1 then selectedItems[0] else null

    @selectItem @constructor._lastPath if @constructor._lastPath

  onDestroyed: ->
    super arguments...

    @_applyPathPartsAutorun?.stop()

    # Remember currently opened folder.
    @constructor._lastPath = _.last(@_directories).options.path

  selectItem: (path) ->
    pathParts = _.trim(path, '/').split '/'

    @_applyPathParts 0, pathParts

  _applyPathParts: (directoryIndex, pathParts) ->
    return unless pathParts.length

    @_applyPathPartsAutorun = Tracker.autorun (computation) =>
      # Wait till the directory has the folder ready.
      return unless directory = @directories()?[directoryIndex]
      return unless directory.isRendered()

      itemPath = "#{directory.options.path}#{pathParts[0]}"

      return unless _.find directory.currentItems(), (item) => item.name is itemPath
      directory.selectItem itemPath
      @focusDirectory directory

      computation.stop()

      Tracker.afterFlush =>
        # Scroll to right.
        $directories = @$('.landsofillusions-assets-editor-filemanager-directory').closest('.directories')
        $directories.scrollLeft 1e8

        @_applyPathParts directoryIndex + 1, pathParts[1..]

  startDrag: (draggedItems) ->
    @draggedItems draggedItems
    
  endDrag: (targetFolder) ->
    return unless @draggedItems()

    for item in @draggedItems()
      continue if item is targetFolder

      nameParts = @constructor.itemNameParts item

      if targetFolder.name.length
        newName = "#{targetFolder.name}/#{nameParts.filename}"

      else
        newName = nameParts.filename

      if item instanceof @constructor.Directory.Folder
        # Move all assets in the folder.
        documents = @directories()[0].documents()

        for document in documents when _.startsWith document.name, item.name
          newDocumentName = document.name.replace item.name, newName
          assetClassName = document.constructor.name

          LOI.Assets.Asset.update assetClassName, document._id,
            $set:
              name: newDocumentName

      else
        # Move the asset from its current path to the new one.
        LOI.Assets.Asset.update item.constructor.className, item._id,
          $set:
            name: newName

    @draggedItems null
    
  focusDirectory: (directory) ->
    @focusedDirectory directory

  selectedItemType: ->
    selectedItem = @currentData()
    selectedItem.constructor.className

  filename: ->
    selectedItem = @currentData()
    @constructor.itemNameParts(selectedItem).filename
