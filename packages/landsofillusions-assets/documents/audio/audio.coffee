AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.Audio extends LOI.Assets.Asset
  @id: -> 'LandsOfIllusions.Assets.Audio'
  # nodes: object of nodes used in this audio.
  #   {id}:
  #     type: node type
  #     position: where the node should appear on the canvas
  #       x
  #       y
  #     expanded: boolean if node's properties are displayed
  #     connections: array of connections to other nodes
  #       output: which of the outputs this connection starts at
  #       nodeId: target node of this connection
  #       input: which of the inputs this connection ties into
  #     parameters: object of current parameter values
  #       {name}: value of the parameter with the given name
  @Meta
    name: @id()

  @className: 'Audio'
  
  # Methods

  @addNode: @method 'addNode'
  @removeNode: @method 'removeNode'
  @updateNode: @method 'updateNode'
  @updateNodeParameters: @method 'updateNodeParameters'
  @updateConnections: @method 'updateConnections'

  @_requireAudio: (audioId) ->
    audio = LOI.Assets.Audio.documents.findOne audioId
    throw new AE.ArgumentException "Audio does not exist." unless audio

    audio

  @_requireNode: (audio, nodeId) ->
    node = audio.nodes?[nodeId]
    throw new AE.InvalidOperationException "Node does not exist." unless node

    node

  @_authorizeAudioAction: ->
    user = Retronator.requireUser()

    return if user.hasItem Retronator.Store.Items.CatalogKeys.Collaborator.AudioEditor
    return if user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

    throw new AE.UnauthorizedException "You are not an audio editor or administrator."
