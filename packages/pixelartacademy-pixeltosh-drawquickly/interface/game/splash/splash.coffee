AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Splash extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Splash'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @drawQuickly = @os.getProgram DrawQuickly
    @game = @parentComponent()
  
  events: ->
    super(arguments...).concat
      'click .play-button': @onClickPlayButton
      'click .quit-button': @onClickQuitButton
      
  onClickPlayButton: (event) ->
    @game.chooseDifficulty()
  
  onClickQuitButton: (event) ->
    @os.unloadProgram @drawQuickly
