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

  _handleNode: (node) ->
    super

    # We don't really have to handle choice node, because the dialog selection
    # module does that, but we still want to pause before we display it.
    @_waitForNode node if node instanceof Nodes.Choice

    @_handlePause node if node instanceof Nodes.Pause

  _handlePause: (pause) ->
    # Just force a wait before going on.
    return if @_waitForNode pause

    pause.end()

  _handleDialogLine: (dialogLine) ->
    return if @_waitForNode dialogLine

    unless dialogLine.actor
      # There is no actor, which means the player is saying this. Simply dump it into the narrative and finish.
      text = @_evaluateLine dialogLine

      @narrative.addText "> \"#{text.toUpperCase()}\""

      dialogLine.end()
      return

    # We have an actor that is saying this.
    dialogColor = dialogLine.actor.color()

    # Add a new paragraph to the narrative
    start = "%%c#{dialogColor.hue}-#{dialogColor.shade}%"
    text = @_evaluateLine dialogLine
    end = 'c%%'

    # Add text transformation.
    switch dialogLine.actor.dialogTextTransform()
      when LOI.Avatar.DialogTextTransform.Lowercase
        start = "%%tL#{start}"
        end = "t%%#{end}"
      when LOI.Avatar.DialogTextTransform.Uppercase
        start = "%%tU#{start}"
        end = "t%%#{end}"

    # Add the intro line at the start.
    unless @_inMultilineDialog
      if dialogLine.actor.dialogDeliveryType() is LOI.Avatar.DialogDeliveryType.Saying
        start = "#{_.upperFirst dialogLine.actor.shortName()} says: #{start}\""

    if dialogLine.next instanceof Nodes.DialogLine and dialogLine.next.actor is dialogLine.actor
      # Next line is by the same actor.
      @_inMultilineDialog = true

    else
      @_inMultilineDialog = false

      # Add the closing quote at the end.
      if dialogLine.actor.dialogDeliveryType() is LOI.Avatar.DialogDeliveryType.Saying
        end = "\"#{end}"

    # Present the text to the player.
    @narrative.addText "#{start}#{text}#{end}"

    # This is a line node so set that we displayed it.
    @_nodeDisplayed dialogLine

    dialogLine.end()

  _handleNarrativeLine: (narrativeLine) ->
    return if @_waitForNode narrativeLine

    # Simply output the line to the narrative.
    text = @_evaluateLine narrativeLine

    @narrative.addText text

    # This is a line node so set that we displayed it.
    @_nodeDisplayed narrativeLine

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
      @narrative.addText "> #{_.upperCase commandLine.line}"

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
