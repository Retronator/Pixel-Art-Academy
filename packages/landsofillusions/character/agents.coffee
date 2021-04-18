AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Agents extends LOI.Adventure.Global
  @id: -> 'LandsOfIllusions.Character.Agents'

  @scenes: -> [
    @Scene
  ]

  @initialize()

  @formatText: (text, keyword, agents) ->
    names = (agent.fullName() for agent in agents)

    # TODO: Support languages other then English.
    agentsText = AB.Rules.English.createNounSeries names

    text = text.replace new RegExp("_#{keyword}_", 'g'), (match) -> agentsText

    text = text.replace /_are_/g, (match) ->
      # TODO: Support languages other then English.
      if names.length > 1 then "are" else "is"

    text
  
  class @Scene extends LOI.Adventure.Scene
    @id: -> 'LandsOfIllusions.Character.Agents.Scene'

    # Activate this scene on the current location/timeline. It can't be null because that would apply it to all
    # locations simultaneously, including things like inventory and apps.
    location: -> LOI.adventure.currentLocationId()
    timelineId: -> LOI.adventure.currentTimelineId()

    @initialize()
  
    constructor: ->
      super arguments...

      # Show characters that have been at the location in the last 15 minutes.
      presenceDurationInMilliseconds = 15 * 60 * 1000

      @recentActionsSubscription = new ComputedField =>
        return unless timelineId = LOI.adventure.currentTimelineId()
        return unless locationId = LOI.adventure.currentLocationId()

        earliestTime = new Date Date.now() - presenceDurationInMilliseconds

        LOI.Memory.Action.recentForTimelineLocation.subscribe timelineId, locationId, earliestTime

      @currentAgents = new ComputedField =>
        # See if we've changed location.
        return [] unless currentTimelineId = LOI.adventure.currentTimelineId()
        return [] unless currentLocationId = LOI.adventure.currentLocationId()

        # Don't process agents until the actions subscription has kicked in,
        # to avoid observing removing and re-adding of actions.
        return [] unless @recentActionsSubscription()?.ready()

        if currentTimelineId isnt @_agentsOldTimelineId or currentLocationId isnt @_agentsOldLocationId
          @_agentsOldTimelineId = currentTimelineId
          @_agentsOldLocationId = currentLocationId
  
          # Mark arrival time so we know which actions to treat as realtime.
          @_agentsTimelineLocationArrivalTime = new Date()
  
          # Clear the agents cache.
          @_agentsById = {}
  
        # Filter all actions to unique characters. We don't care about reactivity
        # of time since we'll only get too many actions and not miss any.
        now = Date.now()
        earliestTime = new Date now - presenceDurationInMilliseconds
  
        actions = LOI.Memory.Action.documents.fetch
          timelineId: currentTimelineId
          locationId: currentLocationId
          time: $gt: earliestTime

        actions = (action.cast() for action in actions)

        # When in a memory context, only set actions, don't transition them.
        inMemoryContext = LOI.adventure.currentContext() instanceof LOI.Memory.Context

        # React only to location and action changes.
        Tracker.nonreactive =>
          # Sort actions by time.
          actions = _.sortBy actions, (action) => action.time.getTime()
  
          oldAgents = _.values @_agentsById

          # Remove non-memorable actions that are past their retain time.
          _.remove actions, (action) =>
            return if action.constructor.isMemorable()
            return unless retainDurationInMilliseconds = action.constructor.retainDuration() * 1000

            earliestRetainTime = new Date now - retainDurationInMilliseconds
            action.time < earliestRetainTime

          # Determine valid actions based on privacy of location/context.
          playerCharacterId = LOI.characterId()
          currentContext = LOI.adventure.currentContext()
          currentContextId = currentContext?.id()

          # See if we're in a private location or in a private context ourselves.
          if LOI.adventure.currentLocation().constructor.isPrivate() or currentContext?.constructor.isPrivate()
            # In private places, no other agents should be present (unless added from other
            # scenes). We only care about the actions of our character in the current context.
            _.remove actions, (action) =>
              action.character._id isnt playerCharacterId or action.contextId isnt currentContextId

          else
            # We're in a public place/context so remove actions performed by characters in private contexts.
            _.remove actions, (action) =>
              # Keep all actions that have no context.
              return unless action.contextId

              # Remove the action if the context is private.
              contextClass = LOI.Adventure.Thing.getClassForId action.contextId
              contextClass.isPrivate()

          # Get all the characters performing the valid actions.
          characterIds = _.uniq (action.character._id for action in actions)

          # Always include player's character.
          characterIds.push playerCharacterId if playerCharacterId and playerCharacterId not in characterIds
  
          # Return a list of characters initialized with their actions.
          for characterId in characterIds
            # Create the agent, if it's new.
            @_agentsById[characterId] ?= LOI.Character.getAgent characterId
  
            lastAction = _.last _.filter actions, (action) -> action.character._id is characterId
  
            if lastAction
              # Convert to correct class.
              lastAction = lastAction.cast()
  
              if lastAction.time < @_agentsTimelineLocationArrivalTime or inMemoryContext
                # Actions happened before we arrived here (or while in a
                # different context), so no need for a transition.
                @_agentsById[characterId].setAction lastAction
  
              else
                @_agentsById[characterId].transitionToAction lastAction
  
            # Remove from old agents.
            _.pull oldAgents, @_agentsById[characterId]
  
          # Notify old agents that they are not at the location any more and remove them.
          for oldAgent in oldAgents
            oldAgent.transitionToAction null
  
            delete @_agentsById[oldAgent.instance._id]
  
          _.values @_agentsById
      ,
        true

    destroy: ->
      super arguments...

      @recentActionsSubscription.stop()
      @currentAgents.stop()

    things: ->
      @currentAgents()
