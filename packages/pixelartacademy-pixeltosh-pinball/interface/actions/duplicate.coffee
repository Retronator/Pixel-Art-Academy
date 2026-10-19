PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Duplicate extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Duplicate'
  @displayName: -> "Duplicate"
  @initialize()

  enabled: ->
    return unless project = @pinball.projectDocument()
    Pinball.Project.editable() and project.name

  execute: ->
    return unless @enabled()
    return unless assetsProvider = @pinball.projectAssetsProvider()
    project = assetsProvider.project

    result = await @os.showInputDialog
      prompt: => project.duplicateAssetsProviderInstructions()
      maxLength: PAA.Practice.Project.nameMaxLength
      buttons: [
        text: "Duplicate"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]

    return unless result?.buttonValue

    name = result.inputValue
    projectId = project.duplicateAssetsProvider assetsProvider, {name}

    # Restart with the player's new copy of the machine.
    file = new Pinball.Project.File projectId
    @pinball.restart file
