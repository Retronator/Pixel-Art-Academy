AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Interface.Text extends LOI.Interface.Text
  initializeNodeHandling: ->
    @_lastNode = new ReactiveField null
    @_pausedNode = new ReactiveField null

    # Reset last node when we're showing the dialog selection or taking command input.
    @autorun (computation) =>
      if @showCommandLine() and not @waitingKeypress()
        # A bit of a hack, but because waiting for keypress might kick back in after the other nodes are reactively
        # processed, we just wait a little bit and see if the conditions are still the same after the wait.
        Meteor.setTimeout =>
          @_lastNode null if @showCommandLine() and not @waitingKeypress()
        ,
          1

  _waitForNode: (node) ->
    # If we're still displaying something, we shouldn't
    # immediately display the node, but instead wait for a key press.
    lastNode = @_lastNode()
    if lastNode
      @_lastNode null

      # Wait for player's command to continue.
      @_pausedNode node

      # Return true to indicate not to handle this node yet.
      return true

    else
      # We don't have a previous node (or it was cleared to continue), so no need to wait. Return false.
      return false

  _nodeDisplayed: (node) ->
    @_lastNode node

    # Remove last node after the scripts have had the chance to advance.
    Tracker.afterFlush =>
      @_lastNode null

  _handleNode: (node, options = {}) ->
    # Text interface doesn't narrate background actions when the interface is busy.
    if options.background and @busy()
      node.cancel()
      return

    super

    # We don't really have to handle choice node, because the dialog selection
    # module does that, but we still want to pause before we display it.
    @_waitForNode node if node instanceof Nodes.Choice

    @_handlePause node if node instanceof Nodes.Pause

  _handlePause: (pause) ->
    # Just force a wait before going on.
    if pause._activated
      pause._activated = false
      pause.end()

    else
      pause._activated = true
      @_lastNode null
      @_pausedNode pause

  _handleDialogueLine: (dialogueLine, options) ->
    return if not options.background and @_waitForNode dialogueLine

    unless dialogueLine.actor
      # There is no actor, which means the player is saying this. Simply dump it into the narrative and finish.
      text = @_evaluateLine dialogueLine

      @narrative.addText "> \"#{text.toUpperCase()}\""

      dialogueLine.end()
      return

    # If the actor is a string, we consider it as a straight-up name.
    if _.isString dialogueLine.actor
      start = ''
      end = ''

    else
      # We have an actor that is saying this.
      dialogueColor = dialogueLine.actor.color()

      # Add a new paragraph to the narrative
      start = "%%c#{dialogueColor.hue}-#{dialogueColor.shade}%"
      end = 'c%%'

      # Add text transformation.
      switch dialogueLine.actor.dialogTextTransform()
        when LOI.Avatar.DialogTextTransform.Lowercase
          start = "%%tL#{start}"
          end = "t%%#{end}"
        when LOI.Avatar.DialogTextTransform.Uppercase
          start = "%%tU#{start}"
          end = "t%%#{end}"

    text = @_evaluateLine dialogueLine

    # Add the intro line at the start.
    unless @_inMultilineDialog
      if _.isString dialogueLine.actor
        actorName = dialogueLine.actor

      else if dialogueLine.actor.dialogueDeliveryType() is LOI.Avatar.DialogueDeliveryType.Saying
        actorName = dialogueLine.actor.shortName()

      start = "#{actorName} says: #{start}\"" if actorName

    if dialogueLine.next instanceof Nodes.DialogueLine and dialogueLine.next.actor is dialogueLine.actor
      # Next line is by the same actor.
      @_inMultilineDialog = true

    else
      @_inMultilineDialog = false

      # Add the closing quote at the end.
      if _.isString(dialogueLine.actor) or dialogueLine.actor.dialogueDeliveryType() is LOI.Avatar.DialogueDeliveryType.Saying
        end = "\"#{end}"

    # Present the text to the player.
    @narrative.addText "#{start}#{text}#{end}", options

    # This is a line node so set that we displayed it, unless we request immediate continuation without pause.
    @_nodeDisplayed dialogueLine unless dialogueLine.immediate

    if options.background
      @_endAfterTextDelay text, dialogueLine

    else
      dialogueLine.end()

  _handleNarrativeLine: (narrativeLine, options) ->
    return if not options.background and @_waitForNode narrativeLine

    # Simply output the line to the narrative.
    text = @_evaluateLine narrativeLine
    
    options.scrollStyle = narrativeLine.scrollStyle

    @narrative.addText text, options

    # This is a line node so set that we displayed it.
    @_nodeDisplayed narrativeLine

    if options.background
      @_endAfterTextDelay text, narrativeLine

    else
      narrativeLine.end()

  _handleInterfaceLine: (interfaceLine) ->
    return if @_waitForNode interfaceLine

    # If the interface line is a silent one, it doesn't appear in the narrative.
    unless interfaceLine.silent
      # Simply output the line to the narrative.
      text = @_evaluateLine interfaceLine

      @narrative.addText text

    # Interface nodes don't stop the narrative and just end.
    interfaceLine.end()

  _handleCommandLine: (commandLine) ->
    return if @_waitForNode commandLine

    # If the command should replace the last command, we delete the previous lines.
    @narrative.removeLastCommand() if commandLine.replaceLastCommand

    # If the command line is a silent one, it doesn't appear in the narrative.
    unless commandLine.silent
      # We act as if the user entered this as a command.
      @narrative.addText "> #{_.toUpper commandLine.line}"

    # Command nodes don't stop the narrative and just end.
    commandLine.end()

  _evaluateLine: (lineNode) ->
    lineNode.line.replace /`(.*?)`/g, (codeSection) ->
      expression = codeSection.match(/`(.*?)`/)[1]
      console.log "Evaluating embedded expression", expression, "from line", lineNode if LOI.debug

      # Create a code node to evaluate the expression.
      codeNode = new LOI.Adventure.Script.Nodes.Code
        expression: expression

      codeNode.script = lineNode.script

      # Evaluate the expression, but we don't allow (or at least react to) state changes within the expression.
      codeNode.evaluate
        triggerChange: false

  _endAfterTextDelay: (text, node) ->
    # We assume reading at ~14 characters/second and include a 3 second buffer.
    delay = 3000 + text.length * 70

    Meteor.setTimeout =>
      node.end()
    ,
      delay
