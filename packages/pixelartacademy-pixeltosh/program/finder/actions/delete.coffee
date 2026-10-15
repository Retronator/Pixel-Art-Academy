PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Actions.Delete extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Actions.Delete'
  @displayName: -> "Delete"

  @initialize()

  constructor: ->
    super arguments...

    @finder = @os.getProgram PAA.Pixeltosh.Programs.Finder

  enabled: ->
    return unless fileOptions = @finder.selectedFile()?.options
    
    if fileOptions.deleteEnabled
      fileOptions.deleteEnabled()
      
    else
      _.isFunction fileOptions.onDelete

  execute: ->
    return unless @enabled()

    file = @finder.selectedFile()
    file.options.onDelete @os
