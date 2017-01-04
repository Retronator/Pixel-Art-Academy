AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Interface.Text extends LOI.Adventure.Interface.Text  
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

  _handleNode: (node) ->
    super

    @_handleChoice node if node instanceof Nodes.Choice

  _handleChoice: (choice) ->
    # We don't really have to handle choice node, because the dialog selection
    # module does that, but we still want to pause before we display it.
    @_waitForNode choice

  _handleDialogLine: (dialogLine) ->
    return if @_waitForNode dialogLine

    unless dialogLine.actor
      # There is no actor, which means the player is saying this. Simply dump it into the narrative and finish.
      text = @_evaluateLine dialogLine

      @narrative.addText "> \"#{text.toUpperCase()}\""

      dialogLine.end()
      return

    # We have an actor that is saying this.
    dialogColor = dialogLine.actor.avatar.colorObject()?.getHexString()

    # Add a new paragraph to the narrative
    start = "%c##{dialogColor}"
    text = @_evaluateLine dialogLine
    end = '%%'

    # Add the intro line at the start.
    unless @_inMultilineDialog
      start = "#{dialogLine.actor.avatar.shortName()} says: #{start}\""

    if dialogLine.next instanceof Nodes.DialogLine and dialogLine.next.actor is dialogLine.actor
      # Next line is by the same actor.
      @_inMultilineDialog = true

    else
      @_inMultilineDialog = false

      # Add the closing quote at the end.
      end = "\"#{end}"

    # Present the text to the player.
    @narrative.addText "#{start}#{text}#{end}"

    # This is a line node so set that we displayed it.
    @_lastNode dialogLine

    dialogLine.end()

  _handleNarrativeLine: (narrativeLine) ->
    return if @_waitForNode narrativeLine

    # Simply output the line to the narrative.
    text = @_evaluateLine narrativeLine

    @narrative.addText text

    # This is a line node so set that we displayed it.
    @_lastNode narrativeLine

    narrativeLine.end()

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
