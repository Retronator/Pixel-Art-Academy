class LandsOfIllusions
  @debug = false

  LOI = @

  # Global Adventure instance.
  LOI.adventure = null
  LOI.adventureInitialized = new ReactiveField false

  constructor: ->
    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage 'pixelart.academy/:parameter1?/:parameter2?/:parameter3?/:parameter4?', LOI.Adventure

  # Character selection and persistence

  @characterIdLocalStorageKey: "LandsOfIllusions.characterId"
  @characterId = new ReactiveField null
  @character = new ReactiveField null

  # Helper to get the default Lands of Illusions palette.
  @palette: ->
    LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.defaultPaletteName

  # Method for switching the current character.
  @switchCharacter: (characterId) ->
    # There's nothing to do if the character is already loaded.
    return if @characterId() is characterId

    # Set the character on the object.
    @characterId characterId

    # Store it in local storage for continuity.
    if characterId
      localStorage.setItem @characterIdLocalStorageKey, characterId

    else
      localStorage.removeItem @characterIdLocalStorageKey

  # Access to package's objects.
  @packages = {}

  @initializePackage: (packageObjects) ->
    @packages[packageObjects.id] = packageObjects

LOI = LandsOfIllusions

if Meteor.isClient
  window.LandsOfIllusions = LOI
  window.LOI = LOI

# On the client load character ID from local storage.
if Meteor.isClient
  localCharacterId = localStorage.getItem LOI.characterIdLocalStorageKey
  LOI.characterId localCharacterId if localCharacterId

# Start account autoruns on client.
if Meteor.isClient
  Meteor.startup ->
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
