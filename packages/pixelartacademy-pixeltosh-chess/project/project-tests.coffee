PAA = PixelArtAcademy
LOI = LandsOfIllusions
Chess = PAA.Pixeltosh.Programs.Chess

# Keep project tests independent of saved profiles and the live adventure.
withChessSets = (callback) ->
  originalAdventure = LOI.adventure
  originalDocuments = PAA.Practice.Project.documents
  originalChessState = Chess.state
  originalBoardDisplayType = Chess.boardDisplayType
  originalProjectState = Chess.Project.TwoDimensional.state
  originalGetWorkbenchInstance = Chess.Project.getWorkbenchInstance

  projects =
    first:
      _id: 'first'
      type: Chess.Project.TwoDimensional.id()
      profileId: 'test-profile'
      assets: [id: 'piece', bitmapId: 'first-bitmap']
    second:
      _id: 'second'
      type: Chess.Project.TwoDimensional.id()
      profileId: 'test-profile'
      name: "Second set"
      assets: [id: 'piece', bitmapId: 'second-bitmap']

  createState = (values = {}) ->
    fields = {}
    (field, value) ->
      fields[field] ?= new ReactiveField values[field]
      fields[field] value if arguments.length is 2
      fields[field]()

  LOI.adventure = profileId: -> 'test-profile'
  Chess.state = createState boardDisplayType: Chess.BoardDisplayTypes.TwoDimensional
  Chess.boardDisplayType = -> Chess.state 'boardDisplayType'
  Chess.Project.TwoDimensional.state = createState()

  # File names use the translated workbench label; avoid constructing a live scene.
  Chess.Project.getWorkbenchInstance = ->
    defaultAssetsProviderName: -> Chess.Project.defaultAssetsProviderName()
  Chess.Project.TwoDimensional.state 'activeProjectId', 'first'

  PAA.Practice.Project.documents =
    findOne: (projectId) -> projects[projectId]
    fetch: (selector) -> _.filter projects, selector
    insert: (project) ->
      project._id = 'new-project'
      projects[project._id] = project
      project._id

  try
    callback projects

  finally
    LOI.adventure = originalAdventure
    PAA.Practice.Project.documents = originalDocuments
    Chess.state = originalChessState
    Chess.boardDisplayType = originalBoardDisplayType
    Chess.Project.TwoDimensional.state = originalProjectState
    Chess.Project.getWorkbenchInstance = originalGetWorkbenchInstance

Tinytest.add 'chess - sets - menu and file select the same active project', (test) ->
  withChessSets (projects) ->
    Chess.state 'projectId2D', 'built-in-2d'
    action = Object.create Chess.Interface.Actions.SelectChessSet.prototype
    action.projectId = 'second'
    test.isFalse action.active()
    action.execute()
    test.equal Chess.currentProjectId(), 'second'
    test.equal Chess.Project.TwoDimensional.state('activeProjectId'), 'second'
    test.equal Chess.state('projectId2D'), null
    test.isTrue action.active()
    test.equal action.displayName(), "Second set"

    Chess.state 'projectId2D', 'built-in-2d'
    file = new Chess.Project.File Chess.Project.TwoDimensional, 'first', {}
    Chess.prototype.openFile.call {constructor: Chess}, file
    test.equal Chess.currentProjectId(), 'first'
    test.equal Chess.state('projectId2D'), null
    test.isFalse action.active()

Tinytest.add 'chess - sets - public selections leave the editable project unchanged', (test) ->
  withChessSets (projects) ->
    projects.public =
      _id: 'public'
      type: Chess.Project.TwoDimensional.id()
      name: "Public set"

    action = Object.create Chess.Interface.Actions.SelectChessSet.prototype
    action.projectId = 'public'
    action.execute()
    test.equal Chess.state('projectId2D'), 'public'
    test.equal Chess.currentProjectId(), 'public'
    test.equal Chess.currentProject(), projects.public
    test.equal Chess.Project.TwoDimensional.state('activeProjectId'), 'first'
    test.isTrue action.active()

    # A published set owned by another profile also uses the program-state override.
    projects.shared = _.extend {}, projects.public, _id: 'shared', profileId: 'another-profile'
    file = new Chess.Project.File Chess.Project.TwoDimensional, 'shared', {}
    Chess.prototype.openFile.call {constructor: Chess}, file
    test.equal Chess.state('projectId2D'), 'shared'
    test.equal Chess.currentProjectId(), 'shared'
    test.equal Chess.Project.TwoDimensional.state('activeProjectId'), 'first'
    test.isFalse action.active()

    # Returning to an owned set clears the override and resumes the active project.
    Chess.activateProject projects.second
    test.equal Chess.currentProjectId(), 'second'
    test.equal Chess.state('projectId2D'), null
    test.equal Chess.Project.TwoDimensional.state('activeProjectId'), 'second'

Tinytest.add 'chess - sets - Finder paths and menu names follow project names', (test) ->
  withChessSets (projects) ->
    file = new Chess.Project.File Chess.Project.TwoDimensional, 'first', {}
    test.equal file.path(), 'Chess Academy/Chess Sets/My Chess Set'
    test.equal file.type().program(), Chess

    projects.first.name = "Renamed set"
    test.equal file.path(), 'Chess Academy/Chess Sets/Renamed set'

    projects.placeholder3D =
      _id: 'placeholder-3d'
      type: Chess.Project.ThreeDimensional.id()
      profileId: 'test-profile'
    projects.public =
      _id: 'public'
      type: Chess.Project.TwoDimensional.id()

    menu = Chess.Interface.createMenuItems()
    themeIndex = _.findIndex menu, caption: 'Theme'
    piecesMenu = menu[themeIndex + 1]
    test.equal piecesMenu.caption, 'Pieces'
    test.equal piecesMenu.type, Chess.Interface.PiecesMenuDropdown.id()
    test.equal piecesMenu.items[0].actionId, Chess.Interface.Actions.OpenChessSetChoice.id()
    test.equal piecesMenu.items[1], null
    test.equal (item.projectId for item in piecesMenu.items.slice(2)), ['first', 'second']

    delete projects.first
    delete projects.second
    test.equal Chess.Interface.PiecesMenuDropdown.createItems(), [actionId: Chess.Interface.Actions.OpenChessSetChoice.id()]

Tinytest.add 'chess - sets - creation preserves the supplied name', (test) ->
  withChessSets (projects) ->
    Chess.Project.TwoDimensional.state 'activeProjectId', null
    Chess.Project.TwoDimensional.start name: "New chess set"
    test.equal Chess.currentProjectId(), 'new-project'
    test.equal projects['new-project'].name, "New chess set"
    test.equal projects['new-project'].profileId, 'test-profile'
    test.equal projects['new-project'].type, Chess.Project.TwoDimensional.id()
    test.equal projects['new-project'].assets, []

Tinytest.add 'chess - sets - project management unlocks with the chess goal', (test) ->
  originalFundamentals = PAA.LearnMode.PixelArtFundamentals
  completed = false

  PAA.LearnMode.PixelArtFundamentals =
    Fundamentals:
      Goals:
        Chess:
          completed: -> completed

  try
    file = new Chess.Project.File Chess.Project.TwoDimensional, 'first', {}
    test.isFalse Chess.Project.TwoDimensional.editable()
    test.isFalse file.options.renameEnabled()
    test.isFalse file.options.deleteEnabled()

    completed = true
    test.isTrue Chess.Project.TwoDimensional.editable()
    test.isTrue file.options.renameEnabled()
    test.isTrue file.options.deleteEnabled()

  finally
    PAA.LearnMode.PixelArtFundamentals = originalFundamentals

Tinytest.add 'chess - sets - providers and copy sources stay within their own set', (test) ->
  withChessSets (projects) ->
    class PieceAsset
      constructor: (@assetsProvider) ->
      destroy: -> @destroyed = true

    originalGetClassForId = PAA.Practice.Asset.getClassForId
    PAA.Practice.Asset.getClassForId = -> PieceAsset

    try
      firstProvider = new Chess.Project.AssetsProvider {}, 'first'
      secondProvider = new Chess.Project.AssetsProvider {}, 'second'
      firstAsset = firstProvider.assets()[0]
      secondAsset = secondProvider.assets()[0]
      test.notEqual firstAsset, secondAsset
      test.equal firstAsset.assetsProvider.assetsData()[0].bitmapId, 'first-bitmap'
      test.equal secondAsset.assetsProvider.assetsData()[0].bitmapId, 'second-bitmap'

      briefComponent =
        bitmap:
          constructor:
            copySourceAssets: -> [PieceAsset]
          assetsProvider: secondProvider

      sources = Chess.Assets.BriefComponent.prototype.copySourceAssets.call briefComponent
      test.equal sources.length, 1
      test.isTrue sources[0] is secondAsset
      test.equal Chess.currentProjectId(), 'first'

    finally
      firstProvider?.destroy()
      secondProvider?.destroy()
      PAA.Practice.Asset.getClassForId = originalGetClassForId

    test.isTrue firstAsset.destroyed
    test.isTrue secondAsset.destroyed

# Construct the real manager with minimal window/layout services for selection-flow tests.
createChessSetChoiceManager = (chess) ->
  originalCreateLayoutsData = Chess.Interface.createLayoutsData
  originalAddWindow = chess.os.addWindow
  Chess.Interface.createLayoutsData = ->
    Menu:
      remainingArea:
        remainingArea:
          tabs: []
    MenuIntro: {}

  chess.os.addWindow = (data) ->
    return 'main' if data.type is PAA.Pixeltosh.Program.View.id()
    originalAddWindow data

  chess.os.interface =
    getWindow: ->
      data: ->
        get: ->
        set: ->
    currentLayoutData: ->
      get: -> {}
      set: ->

  chess.gameManager = -> null
  chess.audioManager = -> introWhenReady: -> true

  try
    new Chess.InterfaceManager chess

  finally
    Chess.Interface.createLayoutsData = originalCreateLayoutsData

Tinytest.add 'chess - sets - missing selection requires board style then a chess set', (test) ->
  withChessSets (projects) ->
    Chess.Project.TwoDimensional.state 'activeProjectId', null
    LOI.adventure.gameStateAvailable = -> true
    windows = []
    removedWindows = []
    focusedWindow = null
    manager = null
    chess =
      autorun: (callback) -> Tracker.autorun callback
      os:
        addWindow: (data) ->
          windows.push data
          windows.length
        removeWindow: (windowId) -> removedWindows.push windowId
        activateWindow: (windowId) -> focusedWindow = windowId

    try
      manager = createChessSetChoiceManager chess
      test.equal Chess.state('boardDisplayType'), Chess.BoardDisplayTypes.TwoDimensional
      test.equal windows.length, 1
      test.equal windows[0].contentComponentId, Chess.Interface.BoardDisplayChoice.id()
      test.isTrue manager.choosingChessSet()

      # Confirming the already-selected style must still advance to chess set selection.
      boardChoice = Object.create Chess.Interface.BoardDisplayChoice.prototype
      boardChoice.chess = interfaceManager: -> manager
      boardChoice.choice = new ReactiveField Chess.state('boardDisplayType')
      test.isUndefined boardChoice.doneButtonDisabledAttribute()
      boardChoice.onClickDoneButton()
      Tracker.flush()
      test.equal windows.length, 2
      test.equal windows[1].contentComponentId, Chess.Interface.ChessSetChoice.id()
      test.isTrue manager.choosingChessSet()

      chooser = Object.create Chess.Interface.ChessSetChoice.prototype
      chooser.chess =
        interfaceManager: -> manager
        os: chess.os
      chooser.selectedProjectId = new ReactiveField null
      test.equal chooser.doneButtonDisabledAttribute(), 'disabled'
      chooser.onClickDoneButton()
      test.isTrue manager.choosingChessSet()

      chooser.selectedProjectId 'deleted-set'
      test.equal chooser.doneButtonDisabledAttribute(), 'disabled'
      chooser.onClickDoneButton()
      test.isTrue manager.choosingChessSet()

      chooser.selectedProjectId 'second'
      test.equal chooser.selectedProject(), projects.second
      test.isUndefined chooser.doneButtonDisabledAttribute()
      chooser.onClickDoneButton()
      Tracker.flush()
      test.equal Chess.currentProjectId(), 'second'
      test.isFalse manager.choosingChessSet()
      test.equal removedWindows, [1, 2]
      test.equal focusedWindow, 'main'
      test.equal windows.length, 2

    finally
      manager?.destroy()

Tinytest.add 'chess - sets - an existing selection skips startup choices', (test) ->
  withChessSets (projects) ->
    LOI.adventure.gameStateAvailable = -> true
    windows = []
    manager = null
    chess =
      autorun: (callback) -> Tracker.autorun callback
      os:
        addWindow: (data) -> windows.push data

    try
      manager = createChessSetChoiceManager chess
      Tracker.flush()
      test.equal windows.length, 0
      test.isFalse manager.choosingChessSet()
      test.equal Chess.currentProjectId(), 'first'

      action = Object.create Chess.Interface.Actions.OpenChessSetChoice.prototype
      action.chess = interfaceManager: -> manager
      action.execute()
      Tracker.flush()
      test.isTrue manager.choosingChessSet()
      test.equal windows.length, 1
      test.equal windows[0].contentComponentId, Chess.Interface.BoardDisplayChoice.id()
      test.equal Chess.state('boardDisplayType'), Chess.BoardDisplayTypes.TwoDimensional
      test.equal Chess.currentProjectId(), 'first'

      # Repeated requests must not add duplicate selection windows.
      action.execute()
      Tracker.flush()
      test.equal windows.length, 1

    finally
      manager?.destroy()

Tinytest.add 'chess - sets - empty selection allows returning to board style', (test) ->
  withChessSets (projects) ->
    delete projects.first
    delete projects.second
    Chess.Project.TwoDimensional.state 'activeProjectId', null
    LOI.adventure.gameStateAvailable = -> true
    windows = []
    removedWindows = []
    manager = null
    chess =
      autorun: (callback) -> Tracker.autorun callback
      os:
        addWindow: (data) ->
          windows.push data
          windows.length
        removeWindow: (windowId) -> removedWindows.push windowId
        activateWindow: ->

    try
      manager = createChessSetChoiceManager chess
      test.equal windows[0].contentComponentId, Chess.Interface.BoardDisplayChoice.id()
      Chess.state 'boardDisplayType', Chess.BoardDisplayTypes.TwoDimensional
      manager.closeBoardDisplayChoice()
      Tracker.flush()
      test.equal windows[1].contentComponentId, Chess.Interface.ChessSetChoice.id()

      chooser = Object.create Chess.Interface.ChessSetChoice.prototype
      chooser.chess =
        interfaceManager: -> manager
        os: chess.os
      chooser.selectedProjectId = new ReactiveField null
      test.equal chooser.projects(), []
      test.equal chooser.doneButtonDisabledAttribute(), 'disabled'
      chooser.onClickDoneButton()
      test.isTrue manager.choosingChessSet()

      chooser.onClickBackButton()
      Tracker.flush()
      test.equal removedWindows, [1, 2]
      test.equal Chess.state('boardDisplayType'), Chess.BoardDisplayTypes.TwoDimensional
      test.equal windows[2].contentComponentId, Chess.Interface.BoardDisplayChoice.id()
      test.isTrue manager.choosingChessSet()

      # Choosing a style again returns to the empty list without bypassing selection.
      Chess.state 'boardDisplayType', Chess.BoardDisplayTypes.TwoDimensional
      manager.closeBoardDisplayChoice()
      Tracker.flush()
      test.equal windows[3].contentComponentId, Chess.Interface.ChessSetChoice.id()
      test.isTrue manager.choosingChessSet()

    finally
      manager?.destroy()
