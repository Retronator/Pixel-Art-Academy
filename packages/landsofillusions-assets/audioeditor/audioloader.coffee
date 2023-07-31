FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioLoader extends FM.Loader
  constructor: ->
    super arguments...

    @_subscription = LOI.Assets.Asset.forId.subscribe LOI.Assets.Audio.className, @fileId

    @audioData = new ComputedField =>
      LOI.Assets.Audio.documents.findOne @fileId
    ,
      true

    # Create the alias for universal operators.
    @asset = @audioData

    @displayName = new ComputedField =>
      return unless audioData = @audioData()
      audioData.name or audioData._id
    ,
      true
    
    # Create the engine audio when context becomes available.
    @audio = new ReactiveField null
    
    @_audioCreateAutorun = Tracker.autorun (computation) =>
      adventureViews = @interface.allChildComponentsOfType LOI.Assets.AudioEditor.AdventureView
      return unless context = adventureViews[0]?.adventure.interface.audioManager.context()
      computation.stop()

      @audio Tracker.nonreactive => new LOI.Assets.Engine.Audio
        context: context
        audioData: @audioData

  destroy: ->
    super arguments...
    
    @_audioCreateAutorun.stop()
    @audio()?.destroy()
    @displayName.stop()
    @audioData.stop()
    @_subscription.stop()
    
  addNode: (options) ->
    nodeType = options.nodeClass.type()

    # Calculate target element's position in audioCanvas.
    audioCanvas = @interface.getEditorForActiveFile()
    elementOffset = $(options.element).offset()
    audioCanvasOffset = audioCanvas.$audioCanvas().offset()

    canvasCoordinate = audioCanvas.camera().transformWindowToCanvas
      x: elementOffset.left - audioCanvasOffset.left
      y: elementOffset.top - audioCanvasOffset.top

    node =
      id: Random.id()
      type: nodeType
      position: canvasCoordinate
      expanded: false

    # Add the node in the database.
    LOI.Assets.Audio.addNode @fileId, node

    audioCanvas.mouse().updateCoordinates options.event

    audioCanvas.startDrag
      nodePosition: canvasCoordinate
      nodeId: node.id
      requireMove: true
      expandOnEnd: true

  removeNode: (nodeId) ->
    # Remove the node in the database
    LOI.Assets.Audio.removeNode @fileId, nodeId

  changeNodeExpanded: (nodeId, expanded) ->
    LOI.Assets.Audio.updateNode @fileId, nodeId, {expanded}

  changeNodePosition: (nodeId, position) ->
    LOI.Assets.Audio.updateNode @fileId, nodeId, {position}

  changeNodeParameter: (nodeId, name, value) ->
    LOI.Assets.Audio.updateNodeParameters @fileId, nodeId,
      "#{name}": value

  addConnection: (nodeId, connection) ->
    LOI.Assets.Audio.updateConnections @fileId, nodeId, connection

  removeConnection: (nodeId, connection) ->
    LOI.Assets.Audio.updateConnections @fileId, nodeId, null, connection

  modifyConnection: (nodeId, connection, oldConnection) ->
    LOI.Assets.Audio.updateConnections @fileId, nodeId, connection, oldConnection
