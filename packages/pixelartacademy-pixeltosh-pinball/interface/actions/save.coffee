PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Save extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Save'
  @displayName: -> "Save"
  @initialize()

  enabled: ->
    return unless project = @pinball.projectDocument()
    Pinball.Project.editable() and not project.name

  execute: ->
    return unless @enabled()
    return unless assetsProvider = @pinball.projectAssetsProvider()

    result = await @os.showInputDialog
      prompt: => assetsProvider.project.nameAssetsProviderInstructions()
      maxLength: PAA.Practice.Project.nameMaxLength
      buttons: [
        text: "Save"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]

    return unless result?.buttonValue
    name = result.inputValue

    assetsProvider.setName name
