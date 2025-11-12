AM = Artificial.Mirage
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.DrawQuickly extends PAA.Pixeltosh.Program
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
  
  load: ->
    super arguments...
    
    @gameMode = new ReactiveField @constructor.GameModes.SymbolicDrawing
    @symbolicDrawing = new @constructor.SymbolicDrawing @
    
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
  
  menuItems: -> @constructor.Interface.createMenuItems()

  update: (gameTime) ->
    @symbolicDrawing.update gameTime
