PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Actions.Rename extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Actions.Rename'
  @displayName: -> "Rename"

  @initialize()

  constructor: ->
    super arguments...

    @finder = @os.getProgram PAA.Pixeltosh.Programs.Finder

  enabled: ->
    return unless fileOptions = @finder.selectedFile()?.options

    if fileOptions.renameEnabled
      fileOptions.renameEnabled()

    else
      _.isFunction fileOptions.onRename

  execute: ->
    return unless @enabled()

    file = @finder.selectedFile()
    file.options.onRename @os
