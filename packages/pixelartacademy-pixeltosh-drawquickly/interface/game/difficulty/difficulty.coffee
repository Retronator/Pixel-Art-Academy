AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Difficulty extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Difficulty'
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
    
  imageUrl: ->
    difficulty = @currentData()
    
    "/pixelartacademy/pixeltosh/programs/drawquickly/difficulty-#{difficulty}.png"
  
  events: ->
    super(arguments...).concat
      'click .difficulty-button': @onClickDifficultyButton
  
  onClickDifficultyButton: (event) ->
    difficulty = @currentData()
    @game.drawQuickly.symbolicDrawing.setDifficulty difficulty
    
    @game.chooseSpeed()
