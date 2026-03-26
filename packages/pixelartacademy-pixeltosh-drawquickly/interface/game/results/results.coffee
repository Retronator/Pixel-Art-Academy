AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Results extends AM.Component
  constructor: ->
    super arguments...
  
  onCreated: ->
    super arguments...
    
    @game = @ancestorComponentOfType DrawQuickly.Interface.Game
  
  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .restart-button': @onClickRestartButton
  
  onClickDoneButton: (event) ->
    @game.backToSplash()
  
  onClickRestartButton: (event) ->
    @game.showInstructions()
