LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.DeleteMachine extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.DeleteMachine'
  @displayName: -> "Delete"
  @initialize()

  enabled: ->
    return unless project = @pinball.projectDocument()
    project.profileId is LOI.adventure.profileId() and Pinball.Project.editable()

  execute: ->
    return unless @enabled()
    return unless assetsProvider = @pinball.projectAssetsProvider()
    project = assetsProvider.project

    result = await @os.showMessageDialog
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
    
    project.deleteAssetsProvider assetsProvider

    # Restart empty.
    @pinball.restart()
