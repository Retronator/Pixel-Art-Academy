FM = FataMorgana
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.PiecesMenuDropdown extends FM.Menu.Dropdown
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.PiecesMenuDropdown'
  @register @id()

  @createItems: ->
    items = [
      actionId: Chess.Interface.Actions.OpenChessSetChoice.id()
    ]

    # Add a divider and items for each board style view if there are any projects available.
    # TODO: Add the 3D project class when available.
    for projectClass in [Chess.Project.TwoDimensional]
      projects = projectClass.getCurrentProfileProjects()
      continue unless projects.length
      
      items.push null
      items.push projectId: project._id for project in projects

    items

  template: -> FM.Menu.Dropdown.id()

  onCreated: ->
    super arguments...

    @_chessSetActions = {}

  onDestroyed: ->
    super arguments...

    action.destroy() for projectId, action of @_chessSetActions

  action: ->
    itemData = @currentData()
    
    if itemData.actionId
      return super arguments...
      
    projectId = itemData.projectId

    # Create a menu action for this project.
    @_chessSetActions[projectId] ?= Tracker.nonreactive => new Chess.Interface.Actions.SelectChessSet @interface, projectId
    @_chessSetActions[projectId]
