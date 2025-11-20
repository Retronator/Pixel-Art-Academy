AM = Artificial.Mirage
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.DrawQuickly extends PAA.Pixeltosh.Program
  # symbolicDrawing: results of symbolic drawing mode
  #   bestScores: object with scores by difficulty
  #     {easy, medium, hard}: object with scores by speed
  #       {slow, medium, fast}: number of drawn things in time
  # realisticDrawing: results of realistic drawing mode
  #   things: an object of drawn things
  #     {thing}: name of the thing
  #       durations: array of results for the 3 durations
  #         drawingId: the ID of the drawing made for this duration
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly'
  @register @id()

  @version: -> '0.1.0'

  @fullName: -> "Draw Quickly"
  @description: ->
    "
      A drawing game for Pixeltosh.
    "
    
  @slug: -> 'drawquickly'

  @initialize()
  
  @GameModes:
    SymbolicDrawing: 'SymbolicDrawing'
    RealisticDrawing: 'RealisticDrawing'
  
  @maxVolume = 0.15
  
  constructor: ->
    super arguments...
    
    @_loadSoundsAutorun = Tracker.autorun (computation) =>
      return unless context = LOI.adventure.audioManager.context()
      audioOutputNode = AEc.Node.Mixer.getOutputNodeForName 'location', context
      
      @timerSecondsSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/drawquickly/timer-seconds.wav', LOI.adventure.audioManager, audioOutputNode
      @timerEndSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/drawquickly/timer-end.wav', LOI.adventure.audioManager, audioOutputNode
      
      computation.stop()
    
  destroy: ->
    @_loadSoundsAutorun.stop()
    
    @timerSecondsSound?.destroy()
    @timerEndSound?.destroy()
  
  load: ->
    super arguments...
    
    @gameMode = @constructor.GameModes.RealisticDrawing
    @symbolicDrawing = new @constructor.SymbolicDrawing @
    @realisticDrawing = new @constructor.RealisticDrawing @
    
    @windowId = @os.addWindow @constructor.Interface.createInterfaceData()
    
    @classifiers =
      symbolic: new @constructor.Classifier.Symbolic
      realistic: new @constructor.Classifier.Realistic
    
    for classifierName, classifier of @classifiers
      await classifier.createInferenceSession()
    
    @app = @os.ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
  
  unload: ->
    super arguments...
    
    @app.removeComponent @
    @symbolicDrawing.destroy()
    @realisticDrawing.destroy()
    
  setGameMode: (@gameMode) ->
  
  menuItems: -> @constructor.Interface.createMenuItems()

  onBackButton: ->
    game = @os.interface.getView DrawQuickly.Interface.Game
    game.onBackButton()
  
  playTimerSeconds: ->
    @timerSecondsSound.play
      volume: @constructor.maxVolume
  
  playTimerEnd: ->
    @timerEndSound.play
      volume: @constructor.maxVolume
    
  update: (gameTime) ->
    @symbolicDrawing.update gameTime
    @realisticDrawing.update gameTime
