AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Interface.Components.DialogSelection
  constructor: (@options) ->
    @command = new ReactiveField ""

    @selectedDialogLine = new ReactiveField null

    # Provide a list of options.
    @choiceNode = new ComputedField =>
      console.log "Dialog selection detected new script nodes." if LOI.debug

      # Listen to current scripts until we find a choice node.
      location = @options.interface.options.adventure.currentLocation()
      if location
        for scriptNode in location.director().currentScripts()
          return scriptNode if scriptNode instanceof Nodes.Choice

      # No choice node was found, so also reset our selected node.
      @selectedDialogLine null

      null

    # Provide a list of dialog line options.
    @dialogLineOptions = new ComputedField =>
      scriptNode = @choiceNode()
      return unless scriptNode

      console.log "Dialog selection is generating dialog line options." if LOI.debug

      choiceNodes = [scriptNode]

      # Follow the next chain and collect choice nodes until you find a
      # non-choice node. Note that choice nodes can be wrapped in conditionals.
      while scriptNode = scriptNode.next
        # Let's see if we have another choice node.
        if scriptNode instanceof Nodes.Choice
          # Looks like we have a choice! Add it to our choices.
          choiceNodes.push scriptNode

        else if scriptNode instanceof Nodes.Conditional and scriptNode.node instanceof Nodes.Choice
          # We have a choice node inside a conditional, let's see if we should add it. We evaluate the
          # conditional, but we don't trigger reactive change to the state since we're doing this from a reactive
          # calculation itself (that might run many times). Thus dialog line conditionals are not a good place to put
          # state changes.
          result = scriptNode.evaluate triggerChange: false

          # Add the embedded choice node to our list.
          choiceNodes.push scriptNode.node if result

        else
          # We have gone over all the choice nodes in the line so we're done.
          break

      console.log "We have collected choice nodes", choiceNodes if LOI.debug

      # Alright, we found all the choices. Set the first node as the initial choice.
      @selectedDialogLine choiceNodes[0].node

      # Return the embedded dialog nodes as the selection.
      choiceNode.node for choiceNode in choiceNodes

    # Capture key events.
    $(document).on 'keydown.dialogSelection', (event) =>
      @onKeyDown event
      
    # Use this to pause dialog selection handling.
    @paused = new ReactiveField false

  destroy: ->
    # Remove key events.
    $(document).off('.dialogSelection')

  confirm: ->
    selectedDialogLine = @selectedDialogLine()
    return unless selectedDialogLine
    
    # Confirms the current selection and transitions the script from the choice to the selected dialog line.
    @options.interface.options.adventure.currentLocation().director().scriptTransition @choiceNode(), selectedDialogLine

  onKeyDown: (event) ->
    return unless @choiceNode() and not @paused()

    console.log "Key down is being processed in dialog selection." if LOI.debug

    switch event.which
      # Up
      when 38
        event.preventDefault()
        @_moveSelection -1
        
      # Down
      when 40
        event.preventDefault()
        @_moveSelection 1

      # Enter
      when 13
        @options?.onEnter?()

  _moveSelection: (offset) ->
    choices = @dialogLineOptions()

    index = _.indexOf choices, @selectedDialogLine()

    newIndex = _.clamp index + offset, 0, choices.length - 1
    @selectedDialogLine choices[newIndex]
