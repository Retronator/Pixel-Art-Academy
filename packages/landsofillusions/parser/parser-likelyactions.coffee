AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Parser extends LOI.Parser
  # Starts a choice interaction between given actions.
  chooseLikelyAction: (likelyActions) ->
    # Nodes are not yet available when parser is defined, so we need to access them here.
    Nodes = LOI.Adventure.Script.Nodes

    # Sort all actions descending by likelihood, precision and priority. Do a preliminary
    # reverse as well, so that the order inside equal ranks will be preserved.
    likelyActions = _.reverse _.sortBy _.reverse(likelyActions), 'likelihood', 'precision', 'priority'

    # Since each alias and translation variant creates its own likely action, multiple can be for the
    # same phrase action. In that case, only include the most likely one in the consideration.

    # Go from start to end of likely actions, and delete all subsequent actions that have the same action.
    likelyActions = _.uniqWith likelyActions, (a, b) =>
      # Consider likely actions with the same phrase action as equal.
      a.phraseAction.action is b.phraseAction.action

    # Keep only the top priority actions of same phrases.
    likelyActions = _.filter likelyActions, (likelyAction, index, collection) ->
      # Remove this action if an earlier exists with the same translated form and higher priority.
      return false if _.find collection[0...index], (earlierLikelyAction) ->
        likelyAction.priority < earlierLikelyAction.priority and likelyAction.translatedForm.join(' ') is earlierLikelyAction.translatedForm.join(' ')

      true

    if LOI.debug
      console.log "We're not sure what the user wanted ... top 10 possibilities:"
      console.log likelyAction.translatedForm.join(' '), likelyAction.likelihood, likelyAction.precision, likelyAction.priority for likelyAction in likelyActions[0...10]

    # If the most likely action is not above 60%, we tell the user we don't understand.
    bestLikelihood = likelyActions[0].likelihood
    bestPrecision = likelyActions[0].precision

    # If the top actions are 100% likely and precise, just filter down to only them.
    if bestLikelihood is 1 and bestPrecision is 1
      likelyActions = _.filter likelyActions, (likelyAction) ->
        likelyAction.likelihood is 1 and likelyAction.precision is 1

    if bestLikelihood <= 0.6
      return false

    # If we're above, there might be more possibilities that are
    # close together. We find all in the range of 0.2 from the best one, but still not below 0.6
    likelyActions = _.filter likelyActions, (likelyAction) =>
      (likelyAction.likelihood > bestLikelihood - 0.2) and (likelyAction.likelihood > 0.6)

    # If all actions that are left have the same likelihood, take the most precise ones.
    equalLikelihood = _.first(likelyActions).likelihood is _.last(likelyActions).likelihood

    if equalLikelihood
      bestPrecision = likelyActions[0].precision

      likelyActions = _.filter likelyActions, (likelyAction) =>
        likelyAction.precision is bestPrecision

    # If all actions that are left have the same likelihood and precision, take the one with the highest priority
    equalPrecision = _.first(likelyActions).precision is _.last(likelyActions).precision

    if equalLikelihood and equalPrecision
      bestPriority = likelyActions[0].priority

      likelyActions = _.filter likelyActions, (likelyAction) =>
        likelyAction.priority is bestPriority

    # If we have only one possibility left, just choose that one (autocorrect style).
    if likelyActions.length is 1
      likelyAction = likelyActions[0]

      commandNodeSequence = @_createCommandNodeSequence likelyAction
      LOI.adventure.director.startNode commandNodeSequence
      return true

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

        # Save likely action so we can re-translate it in below steps.
        choiceNode._likelyAction = likelyAction

        lastChoiceNode = choiceNode

    # Analyze the generated actions to see if any of translated forms are duplicates.
    translatedForms = []
    duplicateForms = []

    testChoiceNode = lastChoiceNode

    loop
      line = testChoiceNode.node.line

      if line in translatedForms
        duplicateForms.push line

      else
        translatedForms.push line

      testChoiceNode = testChoiceNode.next
      break if testChoiceNode.node is cancelNode

    # Now go over again and re-translate the duplicates with more verbose versions.
    testChoiceNode = lastChoiceNode

    loop
      line = testChoiceNode.node.line

      # See if this line is in any of other's translated lines (it's a substring of another form).
      lineIsSubstring = false
      (lineIsSubstring = true if translatedForm.indexOf(line) > -1) for translatedForm in translatedForms when translatedForm isnt line

      if lineIsSubstring or line in duplicateForms
        testChoiceNode.node.line = _.upperFirst @_createIdealForm testChoiceNode._likelyAction, fullNames: true

      testChoiceNode = testChoiceNode.next
      break if testChoiceNode.node is cancelNode

    # The dialog starts with a question to the user.
    questionNode = new Nodes.InterfaceLine
      line: "Did you mean …"
      next: lastChoiceNode

    # Start the created interaction script.
    LOI.adventure.director.startNode questionNode

    # Signal that we've generated a response to the command.
    true
