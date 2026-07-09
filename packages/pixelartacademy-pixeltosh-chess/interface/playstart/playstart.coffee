AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.PlayStart extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.PlayStart'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    
    @players = @data().child('players').value
    
    unless @players()
      @players [
        color: Chess.Piece.Colors.White
        type: Chess.GameManager.PlayerTypes.Human
        level: 1
        index: 0
      ,
        color: Chess.Piece.Colors.Black
        type: Chess.GameManager.PlayerTypes.Computer
        level: 1
        index: 1
      ]

  playerTypeOptions: -> _.values Chess.GameManager.PlayerTypes
  
  playerTypeCheckedAttribute: ->
    playerType = @currentData()
    player = Template.parentData()

    checked: true if player.type is playerType

  levels: -> [1..5]

  levelSelectedClass: ->
    level = @currentData()
    player = Template.parentData()
    
    'selected' if player.level is level
    
  events: ->
    super(arguments...).concat
      'change .type-input': @onChangeTypeInput
      'click .level-button': @onClickLevelButton
      'click .play-button': @onClickPlayButton

  onChangeTypeInput: (event) ->
    playerType = event.target.value
    player = Template.parentData()
    
    players = @players()
    players[player.index].type = playerType
    @players players

  onClickLevelButton: (event) ->
    level = @currentData()
    player = Template.parentData()
    
    players = @players()
    players[player.index].level = level
    @players players
      
  onClickPlayButton: (event) ->
    players = @players()
    
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Play
    @chess.gameManager().startGame
      white: players[0]
      black: players[1]
