LOI = LandsOfIllusions

window.LandsOfIllusions = LOI
window.LOI = LOI

# Try to load character from storage.
localCharacterId = localStorage.getItem LOI.characterIdLocalStorageKey
LOI.characterId localCharacterId if localCharacterId

# Create settings.
LOI.settings = new LOI.Settings

Meteor.startup ->
  # Subscribe to user's characters.
  charactersSubscription = Retronator.Accounts.User.charactersFieldForCurrentUser.subscribe()

  # Create the current character on the client.
  Tracker.autorun ->
    characterId = LOI.characterId()

    # Only react to character changes.
    Tracker.nonreactive =>
      # Destroy the current character if we have it.
      currentCharacter = LOI.character()
      currentCharacter?.destroy()

      if characterId
        # Create new character.
        LOI.character new LOI.Character.Instance characterId

      else
        # We don't have a character any more.
        LOI.character null

  # Automatically unload character if it doesn't belong to the current user.
  Tracker.autorun (computation) ->
    characterId = LOI.characterId()

    # Nothing to do if we don't have a character or if the user/characters haven't been loaded yet.
    return unless characterId and charactersSubscription.ready()

    characters = Retronator.user()?.characters

    unless _.find characters, ((character) -> character._id is characterId)
      LOI.switchCharacter null

  # Persist character choice if we allow storing game state.
  Tracker.autorun (computation) ->
    characterId = LOI.characterId()

    if characterId and LOI.settings.persistGameState.allowed()
      localStorage.setItem LOI.characterIdLocalStorageKey, value

    else
      localStorage.removeItem LOI.characterIdLocalStorageKey
