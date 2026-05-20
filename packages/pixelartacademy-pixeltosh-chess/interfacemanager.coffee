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
    
    @screen = new ReactiveField @constructor.Screens.Menu
    
    @windowId = @chess.os.addWindow Chess.Interface.createInterfaceData()
    
    # Reactively change the interface layout.
    layouts = Chess.Interface.createLayoutsData @
    
    @_layoutAutorun = @chess.autorun (computation) =>
      return unless window = @chess.os.interface.getWindow @windowId
      
      layout = switch @screen()
        when @constructor.Screens.Menu
          Chess.Interface.Layouts.MenuIntro
      
      window.data().set 'contentArea', layouts[layout]
      
  destroy: ->
    @_layoutAutorun.stop()
    
  inMenu: -> @screen() is @constructor.Screens.Menu
  inLesson: -> @screen() is @constructor.Screens.Lesson
  inPlay: -> @screen() is @constructor.Screens.Play
    
  enterScreen: (screen) ->
    return if @screen() is screen
    @screen screen
