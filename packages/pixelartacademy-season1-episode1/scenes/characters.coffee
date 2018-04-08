LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ

class E1.Characters extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Characters'

  @location: ->
    # We are calculating the characters at the current location.
    LOI.adventure.currentLocationId()

  @initialize()

  constructor: ->
    super

    # Show characters that have been at the location in the last 15 minutes.
    durationInSeconds = 15 * 60

    @actionsSubscriptionAutorun = Tracker.autorun (computation) =>
      return unless locationId = LOI.adventure.currentLocationId()

      LOI.Memory.Action.recentForLocation.subscribe locationId, durationInSeconds

    # People are other players' characters.
    @people = new ComputedField =>

      # See if we've changed location.
      currentLocation = LOI.adventure.currentLocationId()

      if currentLocation isnt @_oldLocation
        @_oldLocation = currentLocation

        # Mark arrival time so we know which actions to treat as realtime.
        @_locationArrivalTime = new Date()

        # Clear the people cache.
        @_peopleById = {}

      # Filter all actions to unique characters. We don't care about reactivity
      # of time since we're only show too many actions and not miss any.
      earliestTime = new Date Date.now() - durationInSeconds * 1000

      actions = LOI.Memory.Action.documents.fetch
        'locationId': currentLocation
        time: $gt: earliestTime

      oldPeople = _.values @_peopleById

      # React only to location and action changes.
      Tracker.nonreactive =>
        characterIds = _.uniq (action.character._id for action in actions)

        # Return a list of characters initialized with their actions.
        for characterId in characterIds
          lastAction = _.last _.filter actions, (action) -> action.character._id is characterId

          # Convert to correct class.
          lastAction = lastAction.cast()

          # Create the person, if it's new.
          @_peopleById[characterId] ?= new LOI.Character.Person characterId

          if lastAction.time < @_locationArrivalTime
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

  destroy: ->
    @actionsSubscriptionAutorun.stop()
    @people.stop()

  things: ->
    @people()
