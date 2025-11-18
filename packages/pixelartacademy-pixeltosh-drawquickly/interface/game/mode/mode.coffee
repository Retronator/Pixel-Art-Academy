AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Mode extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Mode'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @drawQuickly = @os.getProgram DrawQuickly
    @game = @parentComponent()
  
  events: ->
    super(arguments...).concat
      'click .symbolic.mode-button': @onClickSymbolicModeButton
      'click .realistic.mode-button': @onClickRealisticModeButton
  
  onClickSymbolicModeButton: (event) ->
    @game.drawQuickly.setGameMode DrawQuickly.GameModes.SymbolicDrawing
    @game.chooseDifficulty()
    
  onClickRealisticModeButton: (event) ->
    @game.drawQuickly.setGameMode DrawQuickly.GameModes.RealisticDrawing
    @game.chooseComplexity()
