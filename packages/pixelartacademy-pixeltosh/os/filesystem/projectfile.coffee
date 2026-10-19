LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.FileSystem.ProjectFile extends PAA.Pixeltosh.OS.FileSystem.File
  constructor: (options) ->
    super _.extend {}, options
    
    @options.renameEnabled ?= => @_editingEnabled()
    @options.onRename ?= (os) => @_onRename os

    @options.deleteEnabled ?= => @_editingEnabled()
    @options.onDelete ?= (os) => @_onDelete os

  _editingEnabled: ->
    {projectClassId} = @data()
    projectClass = LOI.Adventure.Thing.getClassForId projectClassId
    projectClass.editable()

  _onRename: (os) ->
    {projectClassId, projectId} = @data()
    projectClass = LOI.Adventure.Thing.getClassForId projectClassId

    return unless project = projectClass.getWorkbenchInstance()
    assetsProvider = project.getAssetsProvider projectId

    result = await os.showInputDialog
      prompt: => project.nameAssetsProviderInstructions()
      value: assetsProvider.name()
      maxLength: PAA.Practice.Project.nameMaxLength
      buttons: [
        text: "Rename"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]

    return unless result?.buttonValue
    return unless name = result.inputValue?.trim()

    assetsProvider.setName name

  _onDelete: (os) ->
    {projectClassId, projectId} = @data()
    projectClass = LOI.Adventure.Thing.getClassForId projectClassId

    return unless project = projectClass.getWorkbenchInstance()
    
    result = await os.showMessageDialog
      message: => project.deleteAssetsProviderConfirmation()
      buttons: [
        text: "Delete"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]

    return unless result?.buttonValue
    project.deleteAssetsProvider project.getAssetsProvider projectId
