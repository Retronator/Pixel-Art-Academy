AM = Artificial.Mirage
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Interface.Components.DialogueSelection
  constructor: (@options) ->
    @command = new ReactiveField ""

    @selectedDialogueLine = new ReactiveField null
    @selectedDialogueLineIndex = new ReactiveField null

    # Provide a list of options.
    @choiceNode = new ComputedField =>
      console.log "Dialog selection detected new script nodes." if LOI.debug

      # Listen to current scripts until we find a choice node.
      if LOI.adventure.currentLocation()
        scriptNode = LOI.adventure.director.foregroundScriptQueue.currentScriptNode()
        return scriptNode if scriptNode instanceof Nodes.Choice
        return scriptNode if scriptNode instanceof Nodes.ChoicePlaceholder

      # No choice node was found, so also reset our selected node.
      @selectedDialogueLine null
      @selectedDialogueLineIndex null

      null

    # Provide a list of dialog line options.
    @dialogueLineOptions = new ComputedField =>
      scriptNode = @choiceNode()
      return unless scriptNode

      console.log "Dialog selection is generating dialog line options.", scriptNode if LOI.debug

      choiceNodes = []

      # Follow the next chain and collect choice nodes until you find a
      # non-choice node. Note that choice nodes can be wrapped in conditionals.
      loop
        # Let's see if we have another choice node.
        if scriptNode instanceof Nodes.Choice
          # Looks like we have a choice! Add it to our choices.
          choiceNodes.push scriptNode

        else if scriptNode instanceof Nodes.Conditional and scriptNode.node instanceof Nodes.Choice
          # We have a choice node inside a conditional, let's see if we should add it. We evaluate the
          # conditional, but we don't trigger reactive change to the state since we're doing this from a reactive
          # calculation itself (that might run many times). Thus dialog line conditionals are not a good place to put
          # state changes. We also don't run this in reactive context, because we don't want the selection to
          # recompute while we're showing it.
          result = Tracker.nonreactive => scriptNode.evaluate triggerChange: false

          # Add the embedded choice node to our list.
          choiceNodes.push scriptNode.node if result

        else if scriptNode instanceof Nodes.ChoicePlaceholder
          # We have a choice placeholder. We need to update it so it will point its next node to any new nodes.
          scriptNode.update()

        else
          # We have gone over all the choice nodes in the line so we're done.
          break

        break unless scriptNode = scriptNode.next

      console.log "We have collected choice nodes", choiceNodes if LOI.debug

      # Alright, we found all the choices. We select the choice at the
      # previous index to prevent selection changing on recomputations.
      selectIndex = _.clamp @selectedDialogueLineIndex() or 0, 0, choiceNodes.length - 1
      @selectedDialogueLine choiceNodes[selectIndex].node

      # Return the embedded dialog nodes as the selection.
      choiceNode.node for choiceNode in choiceNodes

    # Capture key events.
    $(document).on 'keydown.dialogueSelection', (event) =>
      @onKeyDown event
      
    # Use this to pause dialog selection handling.
    @paused = new ReactiveField false

  destroy: ->
    # Remove key events.
    $(document).off('.dialogueSelection')

  selectDialogLineOption: (option) ->
    options = @dialogueLineOptions()
    index = _.indexOf options, option

    if index < 0
      console.warn "Non-existent option tried to be selected."
      return

    @selectedDialogueLine option
    @selectedDialogueLineIndex index

  confirm: ->
    selectedDialogueLine = @selectedDialogueLine()
    return unless selectedDialogueLine
    
    # Confirms the current selection and transitions the script from the choice to the selected dialog line.
    LOI.adventure.director.scriptTransition @choiceNode(), selectedDialogueLine

    # Reset the selected index.
    @selectedDialogueLineIndex null

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
    choices = @dialogueLineOptions()

    index = _.indexOf choices, @selectedDialogueLine()

    newIndex = (index + offset + choices.length) % choices.length
    @selectedDialogueLine choices[newIndex]
    @selectedDialogueLineIndex newIndex
