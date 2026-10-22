PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.SelectChessSet extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.SelectChessSet'

  constructor: (osInterface, projectId) ->
    super osInterface

    @projectId = projectId

  projectDocument: -> PAA.Practice.Project.documents.findOne @projectId

  displayName: -> @projectDocument()?.name or Chess.Project.defaultAssetsProviderName()

  active: -> Chess.currentProjectId() is @projectId

  enabled: -> super(arguments...) and @projectDocument()?

  execute: -> Chess.activateProject @projectDocument()
