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
      # Filter all actions to unique characters. We don't care about reactivity
      # of time since we're only show too many actions and not miss any.
      earliestTime = new Date Date.now() - durationInSeconds * 1000

      actions = LOI.Memory.Action.documents.fetch
        'locationId': LOI.adventure.currentLocationId()
        time: $gt: earliestTime

      characterIds = _.uniq (action.character._id for action in actions)

      # Don't include player's character (it will be added separately).
      characterIds = _.without characterIds, LOI.characterId()
      
      # Return a list of characters initialized with their actions.
      for characterId in characterIds
        lastAction = _.last _.filter actions, (action) -> action.character._id is characterId
          
        new LOI.Character.Person
          instance: LOI.Character.getInstance characterId
          action: lastAction

  destroy: ->
    @actionsSubscriptionAutorun.stop()
    @people.stop()

  things: ->
    characters = []
    locationId = _.thingId @location()

    character = LOI.character()
    characterLocationId = LOI.adventure.gameState()?.currentLocationId

    # If the player's character is at this location, add it to the scene.
    characters.push character if locationId is characterLocationId

    # Add all the people.
    characters.push @people()...

    characters
