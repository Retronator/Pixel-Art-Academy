LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.NewProject extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.NewProject'
  @slug: -> 'newproject'
  @fullName: -> "New Project"

  @iconUrl: -> '/pixelartacademy/pixeltosh/os/filesystem/document.png'

  @initialize()

  load: (file) ->
    super arguments...

    projectClass = file.data()
    return unless project = projectClass.getWorkbenchInstance()

    result = await @os.showInputDialog
      prompt: => project.nameAssetsProviderInstructions()
      maxLength: PAA.Practice.Project.nameMaxLength
      buttons: [
        text: "Create"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]

    if result.buttonValue
      await project.createAssetsProvider name: result.inputValue
      @os.getProgram(PAA.Pixeltosh.Programs.Finder).deselect()

    @os.unloadProgram @
