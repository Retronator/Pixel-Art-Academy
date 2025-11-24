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
    Mode: 'Mode'
    Difficulty: 'Difficulty'
    Speed: 'Speed'
    Complexity: 'Complexity'
    Thing: 'Thing'
    Instructions: 'Instructions'
    Draw: 'Draw'
    Results: 'Results'
    
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @drawQuickly = @os.getProgram DrawQuickly
    
    @currentScreen = new ReactiveField @constructor.ScreenTypes.Splash

  onBackButton: ->
    switch @currentScreen()
      when @constructor.ScreenTypes.Mode then @backToSplash()
      when @constructor.ScreenTypes.Difficulty, @constructor.ScreenTypes.Complexity then @chooseMode()
      when @constructor.ScreenTypes.Speed then @chooseDifficulty()
      when @constructor.ScreenTypes.Thing then @chooseComplexity()
      when @constructor.ScreenTypes.Instructions, @constructor.ScreenTypes.Results
        switch @drawQuickly.gameMode
          when DrawQuickly.GameModes.SymbolicDrawing then @chooseSpeed()
          when DrawQuickly.GameModes.RealisticDrawing then @chooseThing()
          
      else return
      
    # Inform that we've handled the back button.
    true
    
  chooseMode: ->
    @currentScreen @constructor.ScreenTypes.Mode
    
  chooseDifficulty: ->
    @currentScreen @constructor.ScreenTypes.Difficulty
  
  chooseSpeed: ->
    @currentScreen @constructor.ScreenTypes.Speed
  
  chooseComplexity: ->
    @currentScreen @constructor.ScreenTypes.Complexity

  chooseThing: ->
    @currentScreen @constructor.ScreenTypes.Thing

  showInstructions: ->
    @currentScreen @constructor.ScreenTypes.Instructions
    
  startDrawing: ->
    @currentScreen @constructor.ScreenTypes.Draw
    
  showResults: ->
    @currentScreen @constructor.ScreenTypes.Results
  
  backToSplash: ->
    @currentScreen @constructor.ScreenTypes.Splash

  showBackButton: ->
    @currentScreen() in [
      @constructor.ScreenTypes.Mode
      @constructor.ScreenTypes.Difficulty
      @constructor.ScreenTypes.Speed
      @constructor.ScreenTypes.Complexity
      @constructor.ScreenTypes.Thing
      @constructor.ScreenTypes.Instructions
    ]
    
  events: ->
    super(arguments...).concat
      'click .back-button': @onClickBackButton
  
  onClickBackButton: (event) ->
    @onBackButton()
