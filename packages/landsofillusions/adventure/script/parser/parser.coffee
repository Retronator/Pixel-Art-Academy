LOI = LandsOfIllusions
Nodes = LOI.Adventure.Script.Nodes

class LOI.Adventure.ScriptFile.Parser
  constructor: (@scriptText) ->
    @scriptNodes = {}
    @labels = {}
    @callbacks = {}

    # Break the script down into lines. Line here includes all indented lines following an un-indented line.
    lines = @scriptText.match /^.+$(?:\n[\t ]+.*)*/gm

    # Parse lines from back to front so we always have a next node ready.
    @nextNode = null

    # TODO: Replace with by -1 when upgrading to new CS.
    lines.reverse()
    @_parseLine line for line in lines

    console.log "Script parser has completed and created nodes", @scriptNodes if LOI.debug

    @scriptNodes

  _parseLine: (line) ->
    # Parse the line with matches in the correct order (for example, label must
    # go before script, since script would also match the label regex).
    for parseRoutine in [
      '_parseComment'
      '_parseCallback'
      '_parseLabel'
      '_parseScript'
      '_parseTimeout'
      '_parseChoice'
      '_parseJump'
      '_parseNarrative'
      '_parseDialog'
      '_parseCode'
    ]
      rest = null
      node = @[parseRoutine] line

      # We store which node is next after this line in case our line has a conditional and we have to jump to it.
      nextNodeAfterThisLine = @nextNode

      if _.isArray node
        # We got back a new node and there's more text left to parse.
        [rest, node] = node

        # Is there any actual text left?
        rest = rest.trim()
        rest = null unless rest.length

        # If there's no node and no text left in rest, we've retrieved all we could from this line.
        break unless rest or node

      if node
        # Set the created node as the next node, except on script nodes, which break continuity.
        @nextNode = if node instanceof Nodes.Script then null else node

        # If there is some text left, parse the rest too.
        @_parseLine rest if rest

        # When we've parsed the whole line, see if there is a condition on the line.
        [..., conditionalNode] = @_parseConditional line

        if conditionalNode
          # Wrap the parsed line nodes in the conditional.
          conditionalNode.node = @nextNode
          conditionalNode.next = nextNodeAfterThisLine
          @nextNode = conditionalNode

        # Stop parsing this line.
        break

      # If there is some text left, parse the rest too.
      if rest
        @_parseLine rest

        # Stop parsing this iteration since the rest has already finished parsing in the above call.
        break

  ###
    <!-- Just hanging out here. -->
  ###
  _parseComment: (line) ->
    # Replace all occurrences of comments out of the line.
    newLine = line.replace /<!--.*?-->/g, ''

    # If string was left unchanged, don't return anything so we don't trigger complete re-parsing.
    return null if line is newLine

    # Return the filtered line.
    [newLine, null]

  ####
    ### callback name
  ####
  _parseCallback: (line) ->
    return unless match = line.match /###\s*(.*?)\s*$/

    node = new Nodes.Callback
      name: match[1]
      next: @nextNode

    @callbacks[node.name] ?= []
    @callbacks[node.name].push node

    node

  ###
    ## label name
  ###
  _parseLabel: (line) ->
    return unless match = line.match /##\s*(.*?)\s*$/

    node = new Nodes.Label
      name: match[1]
      next: @nextNode

    @labels[node.name] = node

    node
        
  ###
    # script id
  ###
  _parseScript: (line) ->
    return unless match = line.match /#\s*(.*?)\s*$/

    node = new Nodes.Script
      id: match[1]
      next: @nextNode
      labels: @labels
      callbacks: @callbacks

    # Reset labels and callbacks.
    @labels = {}
    @callbacks = {}

    # Store the script by its id.
    @scriptNodes[node.id] = node

    node

  ###
    actor name: dialog line
    --or--
    actor name:
        dialog line 1
        dialog line 2
  ###
  _parseDialog: (line) ->
    return unless match = line.match /^(\S.*?):((?:.|\n)*)/

    # We have a dialog line and we know who the actor is.
    actor = match[1]
    dialog = match[2]

    # Now match all the separate dialog lines. Note that we also want to match the potentially empty first line.
    lines = dialog.match /^.*$/gm

    nextNode = @nextNode

    # TODO: Replace with by -1 when upgrading to new CS.
    for i in [lines.length - 1..0]
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
    > narrative line
    --or--
    > narrative line 1
      narrative line 2
  ###
  _parseNarrative: (line) ->
    # This method is mainly a copy of the dialog parsing above. See comments above for details.
    # Refactor if maintenance becomes a problem and the code doesn't diverge too much.
    return unless match = line.match /^> ((?:.|\n)*)/

    lines = match[1].match /^.*$/gm
    nextNode = @nextNode

    # TODO: Replace with by -1 when upgrading to new CS.
    for i in [lines.length - 1..0]
      line = lines[i]

      [line, conditionalNode] = @_parseConditional line

      line = line.trim()
      continue unless line.length

      node = new Nodes.NarrativeLine
        line: line
        next: nextNode

      if conditionalNode and i > 0
        conditionalNode.node = node
        conditionalNode.next = nextNode
        node = conditionalNode

      nextNode = node

    nextNode

  ###
    * dialog line -> [label name]
    --or--
    * dialog line
  ###
  _parseChoice: (line) ->
    # Extract the potential conditional out of the line.
    [line, ...] = @_parseConditional line

    return unless match = line.match /\*\s*(.*?)(?:\s->|$)/

    choiceLine = match[1]

    # Get the jump part out of the line.
    result = @_parseJump line
    [..., jumpNode] = result if result

    # Create a dialog node without an actor (the player's character delivers it),
    # followed by the jump (or simply following to the next node if no jump is present).
    dialogNode = new Nodes.DialogLine
      line: choiceLine
      next: jumpNode or @nextNode
      
    # Create a choice node that delivers the line if chosen.
    choiceNode = new Nodes.Choice
      node: dialogNode
      next: @nextNode

    choiceNode

  ###
    `javascript expression`
  ###
  _parseCode: (line) ->
    return unless match = line.match /^`(.*?)`/

    new Nodes.Code
      expression: match[1]
      next: @nextNode

  ###
    any line `javascript condition`
  ###
  _parseConditional: (line) ->
    # We should only consider the first line in (indented) multi-line strings.
    line = line.match(/^.*$/gm)[0]

    # Now detect the line [condition]
    match = line.match /(.+)`(.*)`\s*$/
    return [line, null] unless match

    line = match[1]
    conditionalNode = new Nodes.Conditional
      expression: match[2]

    [line, conditionalNode]

  ###
    any line -> [label name]
    --or--
    -> [label name]
  ###
  _parseJump: (line) ->
    return unless match = line.match /(.*)->\s*\[(.*?)]/

    line = match[1]
    jumpNode = new Nodes.Jump
      labelName: match[2]

    [line, jumpNode]

  ###
    wait number
  ###
  _parseTimeout: (line) ->
    return unless match = line.match /^wait (\d+)/i

    milliseconds = match[1]

    new Nodes.Timeout
      milliseconds: milliseconds
      next: @nextNode
