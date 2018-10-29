AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor extends AM.Component
  @register 'LandsOfIllusions.Assets.AudioEditor'

  constructor: ->
    super arguments...
    
    @world = new ReactiveField null
    @audio = new ReactiveField null

    @audioCanvas = new ReactiveField null
    @nodeLibrary = new ReactiveField null
    @assetsList = new ReactiveField null
    @assetInfo = new ReactiveField null
    @tools = new ReactiveField null
    @actions = new ReactiveField null
    @toolbox = new ReactiveField null

    @audioId = new ComputedField =>
      AB.Router.getParameter 'audioId'

    @audioData = new ComputedField =>
      return unless audioId = @audioId()

      LOI.Assets.Asset.forId.subscribe LOI.Assets.Audio.className, audioId
      LOI.Assets.Audio.documents.findOne audioId
      
    @activeTool = new ReactiveField null

    @interface =
      illustrationSize: new AE.Rectangle 0, 0, 0, 0

    @currentLocationThings = => []

  onCreated: ->
    super arguments...

    $('html').addClass('asset-editor')

    # Initialize components.
    @world new LOI.Engine.World @
    
    @audio new LOI.Assets.Engine.Audio
      world: @world
      audioData: @audioData

    @audioCanvas new @constructor.AudioCanvas @
    @nodeLibrary new @constructor.NodeLibrary @

    setAssetId = (audioId) =>
      AB.Router.setParameters {audioId}
        
    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Audio
      getAssetId: @audioId
      setAssetId: setAssetId

    @assetInfo new LOI.Assets.Components.AssetInfo
      documentClass: LOI.Assets.Audio
      getAssetId: @audioId
      setAssetId: setAssetId
      getPaletteId: @paletteId
      setPaletteId: (paletteId) =>
        LOI.Assets.Audio.update @audioId(), $set: palette: _id: paletteId

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      actions: @actions

    # Create tools.
    toolClasses = [
      @constructor.Tools.Undo
      @constructor.Tools.Redo
    ]

    tools = for toolClass in toolClasses
      new toolClass
        editor: => @
          
    @tools tools

  onDestroyed: ->
    super arguments...

    $('html').removeClass('asset-editor')
    
  addNode: (options) ->
    nodes = @audioData().nodes or {}
    nodeType = options.nodeClass.type()

    # Calculate target element's position in audioCanvas.
    audioCanvas = @audioCanvas()
    elementOffset = $(options.element).offset()
    audioCanvasOffset = audioCanvas.$audioCanvas().offset()

    canvasCoordinate = audioCanvas.camera().transformWindowToCanvas
      x: elementOffset.left - audioCanvasOffset.left
      y: elementOffset.top - audioCanvasOffset.top

    nodeId = Random.id()

    node =
      type: nodeType
      position: canvasCoordinate
      expanded: false

    # Add the node in the database.
    LOI.Assets.Audio.addNode @audioId(), nodeId, node

    audioCanvas.mouse().updateCoordinates options.event

    audioCanvas.startDrag
      nodePosition: canvasCoordinate
      nodeId: nodeId
      requireMove: true

  removeNode: (nodeId) ->
    # Remove the node in the database
    LOI.Assets.Audio.removeNode @audioId(), nodeId

  changeNodeExpanded: (nodeId, expanded) ->
    LOI.Assets.Audio.updateNode @audioId(), nodeId, {expanded}

  changeNodePosition: (nodeId, position) ->
    LOI.Assets.Audio.updateNode @audioId(), nodeId, {position}

  addConnection: (nodeId, connection) ->
    LOI.Assets.Audio.updateConnections @audioId(), nodeId, connection

  removeConnection: (nodeId, connection) ->
    LOI.Assets.Audio.updateConnections @audioId(), nodeId, null, connection

  modifyConnection: (nodeId, connection, oldConnection) ->
    LOI.Assets.Audio.updateConnections @audioId(), nodeId, connection, oldConnection
