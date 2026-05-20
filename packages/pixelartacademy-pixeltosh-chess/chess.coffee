AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Chess extends PAA.Pixeltosh.Program
  # TODO: boardDisplayType: enum whether the camera should be 3D or 3D
  # chessSet2D: the project ID of the currently chosen 2D chess set
  # TODO: chessSet3D: enum whether the camera should be 3D or 3D
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess'
  @register @id()
  
  @version: -> '0.1.0'
  
  @fullName: -> "Chess Academy"
  @description: ->
    "
      Learn how to play chess.
    "
  
  @slug: -> 'chess'
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @interfaceManager = new ReactiveField null
    
    @projectId2D = new AE.LiveComputedField =>
      @state('chessSet2D') or @constructor.Project.TwoDimensional.state('activeProjectId')
    
  destroy: ->
    super arguments...
    
    @projectId2D.stop()
    
  load: ->
    super arguments...

    # Initialize components.
    @interfaceManager new @constructor.InterfaceManager @
    
  unload: ->
    @interfaceManager()?.destroy()
    
    @interfaceManager null
  
  menuItems: -> @constructor.Interface.createMenuItems()
