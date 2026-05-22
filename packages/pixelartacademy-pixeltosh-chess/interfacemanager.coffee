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
    
    # Reactively change the interface layout.
    layouts = Chess.Interface.createLayoutsData @
    
    menuTabs = {}
    
    for tab in layouts[Chess.Interface.Layouts.Menu].remainingArea.remainingArea.tabs
      menuTabs[tab.name.toLowerCase()] = tab
    
    @_layoutAutorun = @chess.autorun (computation) =>
      return unless window = @chess.os.interface.getWindow @windowId
      
      switch @screen()
        when @constructor.Screens.Menu
          if @chess.gameManager().ownedPiecesCount()
            layout = layouts[Chess.Interface.Layouts.Menu]
            
            # Only have play available.
            tabs = [_.clone menuTabs.play]
            tabs[0].active = true
            layout.remainingArea.remainingArea.tabs = tabs
            
          else
            layout = layouts[Chess.Interface.Layouts.MenuIntro]
            
        when @constructor.Screens.Play
          layout = layouts[Chess.Interface.Layouts.Play]
      
      window.data().set 'contentArea', layout
      
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
