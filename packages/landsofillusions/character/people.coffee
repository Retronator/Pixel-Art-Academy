LOI = LandsOfIllusions

class LOI.Character.People extends LOI.Adventure.Global
  @id: -> 'LandsOfIllusions.Character.People'

  @scenes: -> [
    @Scene
  ]

  @initialize()
  
  class @Scene extends LOI.Adventure.Scene
    @id: -> 'LandsOfIllusions.Character.People.Scene'

    # Activate this scene on the current location/timeline. It can't be null because that would apply it to all
    # locations simultaneously, including things like inventory and apps.
    location: -> LOI.adventure.currentLocationId()
    timelineId: -> LOI.adventure.currentTimelineId()

    @initialize()
  
    constructor: ->
      super

      # Show characters that have been at the location in the last 15 minutes.
      durationInMilliseconds = 15 * 60 * 1000

      @recentActionsSubscription = new ComputedField =>
        return unless timelineId = LOI.adventure.currentTimelineId()
        return unless locationId = LOI.adventure.currentLocationId()

        earliestTime = new Date Date.now() - durationInMilliseconds

        LOI.Memory.Action.recentForTimelineLocation.subscribe timelineId, locationId, earliestTime

      @currentPeople = new ComputedField =>
        # See if we've changed location.
        return [] unless currentTimelineId = LOI.adventure.currentTimelineId()
        return [] unless currentLocationId = LOI.adventure.currentLocationId()

        # Don't process people until the actions subscription has kicked in,
        # to avoid observing removing and re-adding of actions.
        return [] unless @recentActionsSubscription()?.ready()

        if currentTimelineId isnt @_peopleOldTimelineId or currentLocationId isnt @_peopleOldLocationId
          @_peopleOldTimelineId = currentTimelineId
          @_peopleOldLocationId = currentLocationId
  
          # Mark arrival time so we know which actions to treat as realtime.
          @_peopleTimelineLocationArrivalTime = new Date()
  
          # Clear the people cache.
          @_peopleById = {}
  
        # Filter all actions to unique characters. We don't care about reactivity
        # of time since we'll only get too many actions and not miss any.
        earliestTime = new Date Date.now() - durationInMilliseconds
  
        actions = LOI.Memory.Action.documents.fetch
          timelineId: currentTimelineId
          locationId: currentLocationId
          time: $gt: earliestTime

        # When in a memory context, only set actions, don't transition them.
        inMemoryContext = LOI.adventure.currentContext() instanceof LOI.Memory.Context

        # React only to location and action changes.
        Tracker.nonreactive =>
          # Sort actions by time.
          actions = _.sortBy actions, (action) => action.time.getTime()
  
          oldPeople = _.values @_peopleById
  
          characterIds = _.uniq (action.character._id for action in actions)

          # Don't include other characters on private locations.
          characterIds = [] if LOI.adventure.currentLocation().isPrivate()

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
  
              if lastAction.time < @_peopleTimelineLocationArrivalTime or inMemoryContext
                # Actions happened before we arrived here (or while in a
                # different context), so no need for a transition.
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

    destroy: ->
      super

      @recentActionsSubscription.stop()
      @currentPeople.stop()

    things: ->
      @currentPeople()
