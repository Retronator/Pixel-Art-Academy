LOI = LandsOfIllusions
Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.Script.Parser
  constructor: (@scriptText) ->
    @scriptNodes = {}

    @currentScriptNode = null
    @previousNode = null
    @activeDialogLine = null

  parse: ->
    # Break the script down into lines. Line here includes all indented lines following an un-indented line.
    lines = @scriptText.match /^.+$(?:\n[\t ]+.*)*/gm

    for line in lines
      # Parse the line with matches in the correct order.
      for parseRoutine in [
        '_parseLabelNode'
        '_parseScriptNode'
        '_parseDialogNode'
      ]
        node = @[parseRoutine] line

        if node
          if _.isArray node
            # Looks like the parser generated a sequence of nodes.
            nodes = node

            # If we have a previous node that doesn't have a next node, the first ouf the new nodes is is successor.
            @previousNode?.next ?= nodes[0]

            # Replace the previous node.
            @previousNode = nodes[-1]
            
          else
            # If we have a previous node that doesn't have a next node, we're its successor.
            @previousNode?.next ?= node

            # Replace the previous node.
            @previousNode = node
          
          # Stop parsing this line.
          break

    console.log "COMPLETED PARSING", @scriptNodes

    @scriptNodes

  ###
    ## label name
  ###
  _parseLabelNode: (line) ->
    return unless match = line.match /##\s*(.*?)\s*$/

    node = new Nodes.Label name: match[1]

    @currentScriptNode.labels[node.name] = node

    node
        
  ###
    # script name
  ###
  _parseScriptNode: (line) ->
    return unless match = line.match /#\s*(.*?)\s*$/

    node = new Nodes.Script name: match[1]

    @scriptNodes[node.name] = node
    @currentScriptNode = node

    node

  ###
    actor name: dialog line
    --or--
    actor name:
        dialog line 1
        dialog line 2
  ###
  _parseDialogNode: (line) ->
    return unless match = line.match /^(\S.*):((?:.|\n)*)/

    # We have a dialog line and we know who the actor is.
    actor = match[1]
    dialog = match[2]

    # Now match all the separate dialog lines.
    lines = dialog.match /^.+$/mg

    previousLine = null
    nodes = for line in lines
      node = new Nodes.DialogLine
        actor: actor
        line: line

      previousLine?.next = node
      previousLine = node

      node

    nodes
