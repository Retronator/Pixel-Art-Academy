PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.ChessSetChoice extends PAA.Pixeltosh.Program.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.ChessSetChoice'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    programId: Chess.id()
    left: 0
    top: 0
    right: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    @selectedProjectId = new ReactiveField null

  projects: -> @chess.interfaceManager().availableChessSets()

  selectedProject: -> _.find @projects(), _id: @selectedProjectId()
  
  projectName: ->
    project = @currentData()
    project.name or _.titleCase Chess.Project.getWorkbenchInstance().defaultAssetsProviderName()

  projectSelectedClass: ->
    project = @currentData()
    'selected' if project._id is @selectedProjectId()

  doneButtonDisabledAttribute: -> 'disabled' unless @selectedProject()

  scrollbars: ->
    vertical:
      enabled: true

  events: ->
    super(arguments...).concat
      'click .set': @onClickSet
      'click .back-button': @onClickBackButton
      'click .done-button': @onClickDoneButton

  onClickSet: (event) ->
    @selectedProjectId @currentData()._id

  onClickBackButton: (event) ->
    @chess.interfaceManager().backToBoardDisplayChoice()

  onClickDoneButton: (event) ->
    return unless project = @selectedProject()
    @chess.interfaceManager().endChessSetChoice project
