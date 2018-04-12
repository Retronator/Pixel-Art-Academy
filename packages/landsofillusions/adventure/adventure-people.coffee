AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializePeople: ->
    # Show characters that have been at the location in the last 15 minutes.
    durationInSeconds = 15 * 60

    @autorun (computation) =>
      return unless locationId = @currentLocationId()

      @_recentActionsSubscription = LOI.Memory.Action.recentForLocation.subscribe @, locationId, durationInSeconds

    @currentPeople = new ComputedField =>
      # See if we've changed location.
      return [] unless currentLocation = @currentLocationId()

      # Don't process people until the actions subscription has kicked in,
      # to avoid observing removing and re-adding of actions.
      return [] unless @_recentActionsSubscription.ready()

      if currentLocation isnt @_peopleOldLocation
        @_peopleOldLocation = currentLocation

        # Mark arrival time so we know which actions to treat as realtime.
        @_peopleLocationArrivalTime = new Date()

        # Clear the people cache.
        @_peopleById = {}

      # Filter all actions to unique characters. We don't care about reactivity
      # of time since we'll only get too many actions and not miss any.
      earliestTime = new Date Date.now() - durationInSeconds * 1000

      actions = LOI.Memory.Action.documents.fetch
        'locationId': currentLocation
        time: $gt: earliestTime

      # If our current context has an associated memory, also add all memory actions.
      context = @currentContext()

      if context instanceof LOI.Memory.Context and context.isCreated()
        if memoryActions = context.memory()?.actions
          # Refresh memory actions and add them to actions.
          actions.push action.refresh() for action in memoryActions

      # React only to location and action changes.
      Tracker.nonreactive =>
        # Sort actions by time.
        actions = _.sortBy actions, (action) => action.time.getTime()

        oldPeople = _.values @_peopleById

        characterIds = _.uniq (action.character._id for action in actions)

        # Always include player's character.
        playerCharacterId = LOI.characterId()
        characterIds.push playerCharacterId if playerCharacterId and playerCharacterId not in characterIds

        # Return a list of characters initialized with their actions.
        for characterId in characterIds
          # Create the person, if it's new.
          @_peopleById[characterId] ?= LOI.Character.getPerson characterId

          lastAction = _.last _.filter actions, (action) -> action.character._id is characterId

          if lastAction
            # Convert to correct class.
            lastAction = lastAction.cast()

            if lastAction.time < @_peopleLocationArrivalTime
              # Actions happened before we arrived here, so no need for a transition.
              @_peopleById[characterId].setAction lastAction

            else
              @_peopleById[characterId].transitionToAction lastAction

          # Remove from old people.
          _.pull oldPeople, @_peopleById[characterId]

        # Notify old people that they are not at the location any more and remove them.
        for oldPerson in oldPeople
          oldPerson.transitionToAction null

          delete @_peopleById[oldPerson.instance._id]

        _.values @_peopleById
    ,
      true

  getCurrentPerson: (characterId) ->
    # Note: we don't use @_peopleById directly so we are reactive.
    _.find @currentPeople(), (person) -> person._id is characterId
