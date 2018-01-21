LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.ChoicePlaceholder extends Script.Node
  constructor: (options) ->
    super

    @id = options.id
    @originalNext = options.next
    
  end: ->
    # Query all the listeners if they want to insert any choices.
    
    responses = for listener in LOI.adventure.currentListeners() when listener.onChoicePlaceholder
      response = new Script.Nodes.ChoicePlaceholder.Response
        scriptId: @script.id()
        placeholderId: @id

      listener.onChoicePlaceholder response

      response

    nodes = _.flatten (response.nodes() for response in responses)

    # Daisy chain choices.
    lastNode = @
    
    for node in nodes
      lastNode.next = node
      lastNode = node
      
    # Link the last node to the original next node.
    lastNode.next = @originalNext

    # Finish transition.
    super

  #  Choice placeholder response collects any dialog choices to add at the placeholder location.
  class @Response
    constructor: (@options) ->
      @scriptId = @options.scriptId
      @placeholderId = @options.placeholderId

      @_nodes = []

    addChoice: (node) ->
      @_nodes.push node

    nodes: -> @_nodes
