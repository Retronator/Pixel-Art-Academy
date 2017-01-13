AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Parser extends LOI.Parser
  # Starts a choice interaction between given actions.
  chooseLikelyAction: (likelyActions) ->
    # Nodes are not yet available when parser is defined, so we need to access them here.
    Nodes = LOI.Adventure.Script.Nodes

    # Sort all actions descending by likelihood.
    likelyActions = _.reverse _.sortBy likelyActions, 'likelihood'

    if LOI.debug
      console.log "We're not sure what the user wanted ... possibilities:"
      console.log likelyAction.translatedPhrase, likelyAction.likelihood for likelyAction in likelyActions

    # If the most likely action is below 0.5, we tell the user we don't understand.
    bestLikelihood = likelyActions[0].likelihood

    if bestLikelihood < 0.5
      LOI.adventure.interface.narrative.addText "I don't know what you mean."
      return

    # If we're above, there might be more possibilities that are
    # close together. We find all in the range of 0.2 from the best one.
    likelyActions = _.filter likelyActions, (likelyAction) => likelyAction.likelihood > bestLikelihood - 0.2

    # Since each alias and translation variant creates its own likely action, multiple can be for the
    # same phrase action. In that case, only include the most likely one in the consideration.

    # Go from start to end of likely actions, and delete all subsequent actions that have the same phrase action.
    likelyActions = _.uniqWith likelyActions, (a, b) =>
      # Consider likely actions with the same phrase action as equal.
      a.phraseAction is b.phraseAction

    # If we have only one possibility left, just choose that one (autocorrect style).
    if likelyActions.length is 1
      likelyAction = likelyActions[0]

      commandNodeSequence = @_createCommandNodeSequence likelyAction
      LOI.adventure.director.startNode commandNodeSequence
      return

    # We still have multiple likely actions. Show a selection of choices for the user to choose from.

    # Last option of the selection is to not do anything.
    cancelNode = new Nodes.CommandLine
      line: "Nevermind"
      silent: true
      replaceLastCommand: true

    lastChoiceNode = new Nodes.Choice
      node: cancelNode

    # For each action, create a choice node. Reverse the nodes so the most likely will show on top.
    for likelyAction in _.reverse likelyActions
      # Skip completely improbably actions.
      continue unless likelyAction.likelihood

      do (likelyAction) =>
        commandNodeSequence = @_createCommandNodeSequence likelyAction

        choiceNode = new Nodes.Choice
          node: commandNodeSequence
          next: lastChoiceNode

        lastChoiceNode = choiceNode

    # The dialog starts with a question to the user.
    questionNode = new Nodes.InterfaceLine
      line: "Did you mean …"
      next: lastChoiceNode

    # Start the created interaction script.
    LOI.adventure.director.startNode questionNode
