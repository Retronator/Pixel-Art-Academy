LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.FileSystem.ProjectFile extends PAA.Pixeltosh.OS.FileSystem.File
  constructor: (options) ->
    super _.extend {}, options
    
    @options.deleteEnabled ?= => @deleteEnabled()
    @options.onDelete ?= (os) => @onDelete os

  deleteEnabled: ->
    {projectClassId} = @data()
    projectClass = LOI.Adventure.Thing.getClassForId projectClassId
    projectClass.editable()

  onDelete: (os) ->
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
