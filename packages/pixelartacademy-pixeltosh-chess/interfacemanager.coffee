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
    
  @BoardDisplayTypes:
    TwoDimensional: 'TwoDimensional'
    ThreeDimensional: 'ThreeDimensional'
  
  constructor: (@chess) ->
    @boardDisplayType = @chess.state.field 'boardDisplayType', default: @constructor.BoardDisplayTypes.TwoDimensional
    @displayBoardCoordinates = @chess.state.field 'displayBoardCoordinates', default: false
    @flippedBoard = new ReactiveField false
    
    @screen = new ReactiveField @constructor.Screens.Menu
    
    @windowId = @chess.os.addWindow Chess.Interface.createInterfaceData()
    
    @_shopWindowId = new ReactiveField null
    
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
          if ownedPiecesCount = @chess.gameManager().ownedPiecesCount()
            layout = layouts[Chess.Interface.Layouts.Menu]
            
            tabs = [_.cloneDeep menuTabs.lessons]
            
            # Play is available once we have all 16 pieces.
            if ownedPiecesCount is 16 or true
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
      
  destroy: ->
    @_layoutAutorun.stop()
    
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

  openShop: ->
    @_shopWindowId @chess.os.addWindow Chess.Interface.Shop.createInterfaceData()
    
  closeShop: ->
    return unless shopWindowId = @_shopWindowId()
    
    @chess.os.removeWindow shopWindowId
    @_shopWindowId null
    
    @chess.os.activateWindow @windowId

  shopIsOpen: -> @_shopWindowId()
