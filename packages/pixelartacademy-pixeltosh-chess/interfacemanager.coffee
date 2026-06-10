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
          if Chess.ownedPiecesCount()
            layout = layouts[Chess.Interface.Layouts.Menu]
            
            tabs = [_.cloneDeep menuTabs.lessons]
            
            # Play is available once king lessons are completed.
            if Chess.Lessons.Categories.King.completed()
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
      
    @_boardDisplayChoiceAutorun = @chess.autorun =>
      return unless LOI.adventure.gameState()
      return unless @window()
      
      # Note: We want to compare to the raw state value to not take the default into account.
      return if Chess.state 'boardDisplayType'
      return if @_boardDisplayChoiceWindowId()
      
      @_boardDisplayChoiceWindowId @chess.os.addWindow Chess.Interface.BoardDisplayChoice.createInterfaceData()
      
    @_earningsAutorun = @chess.autorun =>
      return unless @window()
      return unless @inMenu()
      return unless Chess.pendingRewards().length

      return if @_earningsWindowId()

      @_earningsWindowId @chess.os.addWindow Chess.Interface.Earnings.createInterfaceData()

  destroy: ->
    @window.stop()
    @_layoutAutorun.stop()
    @_boardDisplayChoiceAutorun.stop()
    @_earningsAutorun.stop()
    
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
        
      when @constructor.Screens.Play
        Chess.state 'playStarted', true

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

  autoPromotion: -> Chess.autoPromotion() and not @inLesson()
