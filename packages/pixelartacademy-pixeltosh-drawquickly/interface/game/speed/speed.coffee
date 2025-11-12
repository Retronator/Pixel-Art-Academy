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
      'easy'
      'medium'
      'hard'
    ]
    
  time: ->
    difficulty = @currentData()
    @getTimeForDifficulty difficulty
    
  getTimeForDifficulty: (difficulty) ->
    DrawQuickly.SymbolicDrawing.timePerDifficulty[@drawQuickly.symbolicDrawing.difficulty][difficulty]
  
  minutes: ->
    Math.floor Math.ceil(@time()) / 60
  
  seconds: ->
    seconds = Math.ceil(@time()) % 60
    seconds.toString().padStart 2, '0'
    
  events: ->
    super(arguments...).concat
      'click .difficulty-button': @onClickSpeedButton
  
  onClickSpeedButton: (event) ->
    difficulty = @currentData()
    @game.drawQuickly.symbolicDrawing.setTime @getTimeForDifficulty difficulty
    
    @game.showInstructions()
