PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.New extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.New'
  @displayName: -> "New"
  @initialize()

  enabled: -> Pinball.Project.editable()

  execute: ->
    return unless @enabled()
    return unless project = Pinball.Project.getWorkbenchInstance()

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

    return unless result?.buttonValue
    
    name = result.inputValue?.trim()
    await project.createAssetsProvider {name}

    # Load the new machine.
    await _.waitForFlush()
    file = new Pinball.Project.File project.activeAssetsProvider().id()
    
    # Restart with the new file.
    @pinball.restart file
