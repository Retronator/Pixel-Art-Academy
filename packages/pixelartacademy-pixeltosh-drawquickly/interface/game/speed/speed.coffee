AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Speed extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Speed'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @drawQuickly = @os.getProgram DrawQuickly
    @game = @parentComponent()
  
  difficultyOptions: ->
    [
      'slow'
      'medium'
      'fast'
    ]
    
  time: ->
    speed = @currentData()
    @getTimeForSpeed speed
    
  getTimeForSpeed: (speed) ->
    DrawQuickly.SymbolicDrawing.timePerDifficulty[@drawQuickly.symbolicDrawing.difficulty][speed]
  
  minutes: ->
    Math.floor Math.ceil(@time()) / 60
  
  seconds: ->
    seconds = Math.ceil(@time()) % 60
    seconds.toString().padStart 2, '0'
  
  bestScore: ->
    speed = @currentData()
    DrawQuickly.SymbolicDrawing.getBestScoreForDifficultyAndSpeed @drawQuickly.symbolicDrawing.difficulty, speed
    
  events: ->
    super(arguments...).concat
      'click .difficulty-button': @onClickSpeedButton
  
  onClickSpeedButton: (event) ->
    speed = @currentData()
    @game.drawQuickly.symbolicDrawing.setSpeed speed
    
    @game.showInstructions()
