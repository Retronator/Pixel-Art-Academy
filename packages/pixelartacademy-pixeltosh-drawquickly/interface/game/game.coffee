AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game'
  @register @id()
  
  @ScreenTypes:
    Splash: 'Splash'
    Difficulty: 'Difficulty'
    Speed: 'Speed'
    Instructions: 'Instructions'
    Draw: 'Draw'
    Results: 'Results'
    
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @drawQuickly = @os.getProgram DrawQuickly
    
    @currentScreen = new ReactiveField @constructor.ScreenTypes.Splash
    
  chooseDifficulty: ->
    @currentScreen @constructor.ScreenTypes.Difficulty
  
  chooseSpeed: ->
    @currentScreen @constructor.ScreenTypes.Speed

  showInstructions: ->
    @currentScreen @constructor.ScreenTypes.Instructions
    
  startDrawing: ->
    @currentScreen @constructor.ScreenTypes.Draw
    
  showResults: ->
    @currentScreen @constructor.ScreenTypes.Results
  
  backToSplash: ->
    @currentScreen @constructor.ScreenTypes.Splash
