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
      if characterId
        # Create new character.
        LOI.character LOI.Character.getInstance characterId

      else
        # We don't have a character any more.
        LOI.character null

  # Automatically unload character if it doesn't belong to the current user or its design is revoked.
  Tracker.autorun (computation) ->
    characterId = LOI.characterId()

    # Nothing to do if we don't have a character or if the user/characters haven't been loaded yet.
    return unless characterId and charactersSubscription.ready()

    characters = Retronator.user()?.characters

    characterBelongsToUser = _.find characters, ((character) -> character._id is characterId)
    characterHasApprovedDesign = LOI.Character.documents.findOne(characterId)?.designApproved

    unless characterBelongsToUser and characterHasApprovedDesign
      LOI.switchCharacter null

  # Persist character choice if we allow storing game state.
  Tracker.autorun (computation) ->
    characterId = LOI.characterId()

    if characterId and LOI.settings.persistGameState.allowed()
      localStorage.setItem LOI.characterIdLocalStorageKey, characterId

    else
      localStorage.removeItem LOI.characterIdLocalStorageKey

  # Create and update the singleton default palette texture.
  LOI.paletteTexture = new LOI.Engine.Textures.Palette

  Tracker.autorun (computation) ->
    return unless palette = LOI.palette()
    computation.stop()

    LOI.paletteTexture.update palette
