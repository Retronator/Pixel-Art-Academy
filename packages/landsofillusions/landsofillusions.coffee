class LandsOfIllusions
  @debug = false

  LOI = @

  # Global Adventure instance.
  LOI.adventure = null

  constructor: ->
    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage '/:parameter1?/:parameter2?/:parameter3?/:parameter4?', 'LandsOfIllusions.Adventure'

  # Character selection and persistence

  @characterIdLocalStorageKey: "LandsOfIllusions.characterId"
  @characterId = new ReactiveField null

  # Create the current character helper.
  @character: ->
    @Character.documents.findOne @characterId()

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
  window.LOI = LOI

# On the client load character ID from local storage.
if Meteor.isClient
  localCharacterId = localStorage.getItem LOI.characterIdLocalStorageKey
  LOI.characterId localCharacterId if localCharacterId

# Start account autoruns on client.
if Meteor.isClient
  LOI._charactersSubscription = Meteor.subscribe 'Retronator.Accounts.User.charactersForCurrentUser'

  Meteor.startup ->
    # Reactively subscribe to get all the data for the current character.
    Meteor.autorun ->
      characterId = LOI.characterId()
      return unless characterId

      Meteor.subscribe 'LandsOfIllusions.Character.character', characterId

    # Automatically unload character if it doesn't belong to the current user.
    Meteor.autorun ->
      characterId = LOI.characterId()

      # Nothing to do if we don't have a character or if the user/characters haven't been loaded yet.
      return unless characterId and LOI._charactersSubscription.ready()

      characters = Retronator.user()?.characters

      unless _.find characters, ((character) -> character._id is characterId)
        LOI.switchCharacter null
