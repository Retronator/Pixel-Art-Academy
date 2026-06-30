AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.AudioManager
  @maxVolume = 1
  @soundsPath = '/pixelartacademy/pixeltosh/programs/chess'

  constructor: (@chess) ->
    @_loadSoundsAutorun = Tracker.autorun (computation) =>
      return unless context = LOI.adventure.audioManager.context()
      audioOutputNode = AEc.Node.Mixer.getOutputNodeForName 'location', context

      @checkSound = @_createSound 'check.wav', audioOutputNode
      @checkmateSound = @_createSound 'checkmate.wav', audioOutputNode
      @drawFiftyMoveRuleSound = @_createSound 'draw-fiftymoverule.wav', audioOutputNode
      @drawInsufficientMaterialSound = @_createSound 'draw-insufficientmaterial.wav', audioOutputNode
      @drawThreefoldRepetitionSound = @_createSound 'draw-threefoldrepetition.wav', audioOutputNode
      @gameOverSound = @_createSound 'gameover.wav', audioOutputNode
      @introSound = @_createSound 'intro.wav', audioOutputNode
      @lessonCompleteSound = @_createSound 'lessoncomplete.wav', audioOutputNode
      @stalemateSound = @_createSound 'stalemate.wav', audioOutputNode
      @winBlackSound = @_createSound 'win-black.wav', audioOutputNode
      @winWhiteSound = @_createSound 'win-white.wav', audioOutputNode
      @youWinSound = @_createSound 'youwin.wav', audioOutputNode

      computation.stop()

  destroy: ->
    @_loadSoundsAutorun.stop()

    @checkSound?.destroy()
    @checkmateSound?.destroy()
    @drawFiftyMoveRuleSound?.destroy()
    @drawInsufficientMaterialSound?.destroy()
    @drawThreefoldRepetitionSound?.destroy()
    @gameOverSound?.destroy()
    @introSound?.destroy()
    @lessonCompleteSound?.destroy()
    @stalemateSound?.destroy()
    @winBlackSound?.destroy()
    @winWhiteSound?.destroy()
    @youWinSound?.destroy()
  
  announceState: (state) ->
    # Let the move animation complete.
    await _.waitForSeconds 0.5
    
    if state.checkmate()
      @_play @checkmateSound
      
      if gameOptions = @chess.gameManager()?.gameOptions()
        await _.waitForSeconds 1.2
        
        if gameOptions.white.type is gameOptions.black.type
          if state.turn() is Chess.Piece.Colors.White
            @_play @winBlackSound
            
          else
            @_play @winWhiteSound
          
        else
          humanColor = if gameOptions.white.type is Chess.GameManager.PlayerTypes.Human then Chess.Piece.Colors.White else Chess.Piece.Colors.Black
          
          if state.turn() is humanColor
            @_play @gameOverSound
          
          else
            @_play @youWinSound
    
    else if state.stalemate()
      @_play @stalemateSound
      
    else if state.check()
      @_play @checkSound
      
    if draw = @chess.gameManager()?.draw()
      switch draw
        when Chess.DrawTypes.FiftyMoveRule
          @_play @drawFiftyMoveRuleSound
          
        when Chess.DrawTypes.InsufficientMaterial
          @_play @drawInsufficientMaterialSound
          
        when Chess.DrawTypes.ThreefoldRepetition
          @_play @drawThreefoldRepetitionSound

  introWhenReady: ->
    return unless @introSound.ready()
    
    @_play @introSound
    
    true

  lessonComplete: ->
    return if @_playedLessonComplete
    
    @_play @lessonCompleteSound
    @_playedLessonComplete = true

  _createSound: (fileName, audioOutputNode) ->
    new AEc.Sound "#{@constructor.soundsPath}/#{fileName}", LOI.adventure.audioManager, audioOutputNode

  _play: (sound) ->
    sound?.play
      volume: @constructor.maxVolume
