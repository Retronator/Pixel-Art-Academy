AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Actions.DuplicateNode extends LOI.Assets.Editor.Actions.AssetAction
  enabled: ->
    super(arguments...) and @_nodeIdToDuplicate()
    
  execute: ->
    loader = @interface.getLoaderForActiveFile()
    loader.duplicateNode @_nodeIdToDuplicate(), @constructor.duplicateConnections()
    
  _nodeIdToDuplicate: ->
    audioCanvas = @interface.getEditorForActiveFile()
    audioCanvas.selectedNodeId() or audioCanvas.hoveredNodeId()

class LOI.Assets.AudioEditor.Actions.DuplicateNodeWithoutConnections extends LOI.Assets.AudioEditor.Actions.DuplicateNode
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Actions.DuplicateNodeWithoutConnections'
  @displayName: -> "Duplicate node"
  
  @initialize()
  
  @duplicateConnections: -> false
  
class LOI.Assets.AudioEditor.Actions.DuplicateNodeWithConnections extends LOI.Assets.AudioEditor.Actions.DuplicateNode
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Actions.DuplicateNodeWithConnections'
  @displayName: -> "Duplicate node with connections"
  
  @initialize()
  
  @duplicateConnections: -> true
