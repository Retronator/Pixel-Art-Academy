AM = Artificial.Mirage
AT = Artificial.Telepathy
LOI = LandsOfIllusions

class LOI.Accounts
  @CharacterIdLocalStorageKey:  "LandsOfIllusions.characterId"
  @_characterId = new ReactiveField null

  # Method for switching the current character.
  @switchCharacter: (characterId) ->
    # There's nothing to do if the character is already loaded.
    return if @_characterId() is characterId

    # Set the character on the object.
    @_characterId characterId

    # Store it in local storage for continuity.
    if characterId
      localStorage.setItem @CharacterIdLocalStorageKey, characterId

    else
      localStorage.removeItem @CharacterIdLocalStorageKey

    # Store it to the accounts server so the switch will be registered on other LOI apps.
    LOI.Accounts.Components.LocalData.instance()?.switchCharacter characterId

# On the client load character ID from local storage.
if Meteor.isClient
  localCharacterId = localStorage.getItem LOI.Accounts.CharacterIdLocalStorageKey
  LOI.Accounts._characterId localCharacterId if localCharacterId

# Start account autoruns on client.
if Meteor.isClient
  Meteor.startup ->
    # Reactively subscribe to get all the data for the current character.
    Meteor.autorun ->
      characterId = LOI.characterId()
      return unless characterId

      Meteor.subscribe 'character', characterId

    # Automatically unload character if it doesn't belong to the current user.
    Meteor.autorun ->
      characterId = LOI.characterId()
      characters = LOI.user()?.characters

      # Nothing to do if we don't have a character or if the user/characters haven't been loaded yet.
      return unless characterId and characters

      unless _.find characters, ((character) -> character._id is characterId)
        console.log "I guess characterId is just not present."
        LOI.Accounts.switchCharacter null
