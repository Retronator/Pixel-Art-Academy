LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.ChoicePlaceholder extends Script.Node
  constructor: (options) ->
    super arguments...

    @id = options.id
    @originalNext = options.next
    
  update: ->
    # Query all the listeners if they want to insert any choices.
    responses = for listener in LOI.adventure.currentListeners() when listener.onChoicePlaceholder
      response = new Script.Nodes.ChoicePlaceholder.Response
        script: @script
        placeholderId: @id

      listener.onChoicePlaceholder response

      response

    # Get choice nodes sorted by priority
    choices = _.flatten (response.choices for response in responses)
    prioritizedChoices = _.sortBy choices, (choice) => -(choice.options.priority or 0)
    nodes = (choice.node for choice in prioritizedChoices)

    # Daisy chain choices.
    lastNode = @
    
    for node in nodes
      lastNode.next = node
      lastNode = node
      
    # Link the last node to the original next node.
    lastNode.next = @originalNext

  end: ->
    @update()

    # Finish transition.
    super arguments...

  #  Choice placeholder response collects any dialog choices to add at the placeholder location.
  class @Response
    constructor: (@options) ->
      @script = @options.script
      @scriptId = @options.script.id()
      @placeholderId = @options.placeholderId

      @choices = []

    addChoice: (node, options = {}) ->
      @choices.push {node, options}

    addChoices: (node, options = {}) ->
      while node and (node instanceof Script.Nodes.Choice) or (node.node instanceof Script.Nodes.Choice)
        @addChoice node, options
        node = node.originalNext or node.next
