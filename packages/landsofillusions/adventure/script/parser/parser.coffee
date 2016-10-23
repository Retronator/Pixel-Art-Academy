LOI = LandsOfIllusions
Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.ScriptFile.Parser
  constructor: (@scriptText) ->
    @scriptNodes = {}
    @labels = {}

    # Break the script down into lines. Line here includes all indented lines following an un-indented line.
    lines = @scriptText.match /^.+$(?:\n[\t ]+.*)*/gm

    # Parse lines from back to front so we always have a next node ready.
    @nextNode = null

    # TODO: Replace with by -1 when upgrading to new CS.
    lines.reverse()
    for line in lines
      # Parse the line with matches in the correct order (for example, label must
      # go before script, since script would also match the label regex).
      for parseRoutine in [
        '_parseLabelNode'
        '_parseScriptNode'
        '_parseDialogNode'
      ]
        node = @[parseRoutine] line

        if node
          # See if there is a condition on the line.
          [..., conditionalNode] = @_parseConditional line

          if conditionalNode
            # Embed returned node in the conditional.
            conditionalNode.node = node
            conditionalNode.next = @nextNode
            node = conditionalNode

          # Set the created node as the next node, except on script nodes, which break continuity.
          @nextNode = if node instanceof Nodes.Script then null else node

          # Stop parsing this line.
          break

    console.log "COMPLETED PARSING", @scriptNodes

    @scriptNodes

  ###
    ## label name
  ###
  _parseLabelNode: (line) ->
    return unless match = line.match /##\s*(.*?)\s*$/

    node = new Nodes.Label
      name: match[1]
      next: @nextNode

    @labels[node.name] = node

    node
        
  ###
    # script name
  ###
  _parseScriptNode: (line) ->
    return unless match = line.match /#\s*(.*?)\s*$/

    node = new Nodes.Script
      name: match[1]
      next: @nextNode
      labels: @labels

    # Reset the labels.
    @labels = {}

    # Store the script by name
    @scriptNodes[node.name] = node

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

    # Now match all the separate dialog lines. Note that we also want to match the potentially empty first line.
    lines = dialog.match /^.*$/gm

    nextNode = @nextNode

    # TODO: Replace with by -1 when upgrading to new CS.
    for i in [lines.length-1..0]
      line = lines[i]
      # Extract the conditional out of the line.
      [line, conditionalNode] = @_parseConditional line

      # Make sure there is some text left in the line.
      line = line.trim()
      continue unless line.length

      node = new Nodes.DialogLine
        actor: actor
        line: line
        next: nextNode

      # If we have a conditional, embed the dialog line in it - except in the first line
      # where it will be added by the main conditional detector outside this function.
      #
      # This is not really a recommended syntax, but note that ...
      #
      #   actor name: dialog line 1 [condition]
      #     dialog line 2
      #
      # ... is the equivalent of:
      #
      #   actor name: [condition]
      #     dialog line 1
      #     dialog line 2
      #
      # ... and not:
      #
      #   actor name:
      #     dialog line 1 [condition]
      #     dialog line 2
      #
      if conditionalNode and i > 0
        conditionalNode.node = node
        conditionalNode.next = nextNode
        node = conditionalNode

      # Update the next node in this internal sequence.
      nextNode = node

    # Return the final node (the one at the start of the dialog).
    nextNode

  ###
    any line [javascript condition]
  ###
  _parseConditional: (line) ->
    # We should only consider the first line in (indented) multi-line strings.
    line = line.match(/^.*$/gm)[0]

    # Now detect the line [condition]
    match = line.match /(.*)\[(.*)]/
    return [line, null] unless match

    line = match[1]
    conditionalNode = new Nodes.Conditional
      expression: match[2]

    [line, conditionalNode]
