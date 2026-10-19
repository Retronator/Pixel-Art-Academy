PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.Rename extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.Rename'
  @displayName: -> "Rename"
  @initialize()

  enabled: ->
    return unless project = @pinball.projectDocument()
    Pinball.Project.editable() and project.name and project.profileId is LOI.adventure.profileId()

  execute: ->
    return unless @enabled()
    return unless assetsProvider = @pinball.projectAssetsProvider()

    result = await @os.showInputDialog
      prompt: => assetsProvider.project.nameAssetsProviderInstructions()
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
    name = result.inputValue

    assetsProvider.setName name
