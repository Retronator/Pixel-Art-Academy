AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.FileManager'
  @register @id()

  @itemNameParts: (item, rootPath = '') ->
    name = item.name.substring rootPath.length
    nameParts = name.split '/'

    # Last part is always the filename, the rest is the path.
    filename = _.last nameParts
    folders = _.initial nameParts

    path = folders.join '/'

    {path, folders, filename}

  constructor: (@options) ->
    super arguments...

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

        if selectedItems.length is 1 and selectedItems[0] instanceof @constructor.Directory.Folder
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
    
  startDrag: (draggedItems) ->
    @draggedItems draggedItems
    
  endDrag: (targetFolder) ->
    return unless @draggedItems()

    for item in @draggedItems()
      if item instanceof @constructor.Directory.Folder
        # Move all assets in the folder.
        console.log "dragging a folder"

      else
        # Move the asset from its current path to the new one.
        nameParts = @constructor.itemNameParts item
        newName = "#{targetFolder.name}/#{nameParts.filename}"

        LOI.Assets.Asset.update item.constructor.className, item._id,
          $set:
            name: newName

    @draggedItems null
