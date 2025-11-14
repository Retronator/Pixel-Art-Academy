AM = Artificial.Mirage
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.DrawQuickly extends PAA.Pixeltosh.Program
  # realisticDrawing: results of realistic drawing mode
  #   things: an object of drawn things
  #     {thing}: name of the thing
  #       durations: array of results for the 5 durations
  #         drawingId: the ID of the drawing made for this duration
  #         score: total classifier scores
  #           realistic, symbolic
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

  update: (gameTime) ->
    @symbolicDrawing.update gameTime
    @realisticDrawing.update gameTime
