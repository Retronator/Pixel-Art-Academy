AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.InterfaceManager
  @Screens:
    Menu: 'Menu'
    Lesson: 'Lesson'
    Play: 'Play'
  
  constructor: (@chess) ->
    @flippedBoard = new ReactiveField false
    
    @screen = new ReactiveField @constructor.Screens.Menu
    
    @windowId = @chess.os.addWindow Chess.Interface.createInterfaceData()
    
    @_shopWindowId = new ReactiveField null
    @_boardDisplayChoiceWindowId = new ReactiveField null
    @_earningsWindowId = new ReactiveField null
    
    # Reactively change the interface layout.
    layouts = Chess.Interface.createLayoutsData @
    
    menuTabs = {}
    
    for tab in layouts[Chess.Interface.Layouts.Menu].remainingArea.remainingArea.tabs
      menuTabs[tab.name.toLowerCase()] = tab
      
    @window = new AE.LiveComputedField =>
      @chess.os.interface.getWindow @windowId
    ,
      (a, b) => a is b
    
    @_layoutAutorun = @chess.autorun (computation) =>
      return unless window = @window()
      
      switch @screen()
        when @constructor.Screens.Menu
          ownedPiecesCount = Chess.ownedPiecesCount()
          
          if ownedPiecesCount
            layout = layouts[Chess.Interface.Layouts.Menu]
            
            tabs = [_.cloneDeep menuTabs.lessons]
            
            # Play is available once you have 16 pieces and king lessons are completed.
            if ownedPiecesCount is 16 and Chess.Lessons.Categories.King.completed()
              tabs.push _.cloneDeep menuTabs.play

            # Persist active tab across reflows.
            Tracker.nonreactive =>
              currentLayout = window.data().get 'contentArea'
              activeIndex = _.findIndex currentLayout?.remainingArea?.remainingArea?.tabs, (tab) => tab.active
              
              tabs[if activeIndex >= 0 then activeIndex else 0].active = true
              
            layout.remainingArea.remainingArea.tabs = tabs
            
          else
            layout = layouts[Chess.Interface.Layouts.MenuIntro]
            
        when @constructor.Screens.Lesson
          layout = layouts[Chess.Interface.Layouts.Lesson]
            
        when @constructor.Screens.Play
          layout = layouts[Chess.Interface.Layouts.Play]
      
      Tracker.nonreactive => window.data().set 'contentArea', layout
      
    @_themeAutorun = @chess.autorun (computation) =>
      layoutData = @chess.os.interface.currentLayoutData()
      windows = layoutData.get 'windows'
      styleClass = "#{_.kebabCase @interfaceTheme()}-interface"
      
      Tracker.nonreactive =>
        chessWindows = _.filter windows, (window) => window.programId is Chess.id()
        window.styleClass = styleClass for window in chessWindows
        layoutData.set 'windows', windows
        
    @_boardDisplayChoiceAutorun = @chess.autorun =>
      return unless LOI.adventure.gameStateAvailable()
      return unless @window()
      
      # Note: We want to compare to the raw state value to not take the default into account.
      return if Chess.state 'boardDisplayType'
      return if @_boardDisplayChoiceWindowId()
      
      @_boardDisplayChoiceWindowId @chess.os.addWindow Chess.Interface.BoardDisplayChoice.createInterfaceData()

    @_autoFlipBoardAutorun = @chess.autorun =>
      return unless gameManager = @chess.gameManager()
      return unless gameState = gameManager.gameState()
      
      flippedBoard = @automaticBoardOrientationForGameState gameState
      return unless flippedBoard?

      @flippedBoard flippedBoard
      
    @_earningsAutorun = @chess.autorun =>
      return unless @window()
      return unless @inMenu()
      return unless Chess.pendingRewards().length

      return if @_earningsWindowId()

      @_earningsWindowId @chess.os.addWindow Chess.Interface.Earnings.createInterfaceData()

    @_introAudioAutorun = @chess.autorun (computation) =>
      return unless LOI.adventure.gameStateAvailable()
      return unless @window()
      
      if Chess.ownedPiecesCount()
        computation.stop()
        return
        
      return if @_boardDisplayChoiceWindowId()
      return unless @chess.audioManager().introWhenReady()
      computation.stop()
  
  destroy: ->
    @window.stop()
    @_layoutAutorun.stop()
    @_themeAutorun.stop()
    @_boardDisplayChoiceAutorun.stop()
    @_autoFlipBoardAutorun.stop()
    @_earningsAutorun.stop()
    @_introAudioAutorun.stop()
    
  inMenu: -> @screen() is @constructor.Screens.Menu
  inLesson: -> @screen() is @constructor.Screens.Lesson
  inPlay: -> @screen() is @constructor.Screens.Play
  
  enterScreen: (screen) ->
    return if @screen() is screen
    @screen screen
    
    switch screen
      when @constructor.Screens.Menu
        @chess.gameManager().endGame()
        @chess.lessonManager().endLesson()
        
    # Reset temporary chessboard data.
    chessboardData = @chess.os.interface.getComponentData Chess.Interface.Chessboard
    chessboardData.value {}

  openShop: ->
    @_shopWindowId @chess.os.addWindow Chess.Interface.Shop.createInterfaceData()
    
  closeShop: ->
    return unless shopWindowId = @_shopWindowId()
    
    @chess.os.removeWindow shopWindowId
    @_shopWindowId null
    
    @chess.os.activateWindow @windowId

  shopIsOpen: -> @_shopWindowId()
  
  closeBoardDisplayChoice: ->
    return unless boardDisplayChoiceWindowId = @_boardDisplayChoiceWindowId()

    @chess.os.removeWindow boardDisplayChoiceWindowId
    @_boardDisplayChoiceWindowId null

    @chess.os.activateWindow @windowId
    
  getBoardDisplayChoice: ->
    return unless boardDisplayChoiceWindowId = @_boardDisplayChoiceWindowId()
    return unless window = @chess.os.interface.getWindow boardDisplayChoiceWindowId
    window.childComponentsOfType(Chess.Interface.BoardDisplayChoice)[0]

  closeEarnings: ->
    return unless earningsWindowId = @_earningsWindowId()

    @chess.os.removeWindow earningsWindowId
    @_earningsWindowId null

    @chess.os.activateWindow @windowId
    
  displayBoardCoordinates: -> Chess.displayBoardCoordinates() or @inLesson()

  interfaceTheme: -> Chess.currentProject()?.interfaceTheme or Chess.InterfaceThemes.Light

  chessboardTheme: -> Chess.currentProject()?.chessboardTheme or Chess.ChessboardThemes.Contrast
  
  autoPromotion: -> Chess.autoPromotion() and not @inLesson()

  automaticBoardOrientationForGameState: (gameState) ->
    # Automatic orientation is only active for a human player at a live, unfinished position.
    return unless Chess.autoFlipBoard()
    return if gameState.finished()
    return unless gameManager = @chess.gameManager()
    return unless gameManager.displayingLivePosition()
    return unless options = gameManager.gameOptions()

    currentPlayer = if gameState.turn() is Chess.Piece.Colors.White then options.white else options.black
    return unless currentPlayer.type is Chess.GameManager.PlayerTypes.Human

    gameState.turn() is Chess.Piece.Colors.Black
