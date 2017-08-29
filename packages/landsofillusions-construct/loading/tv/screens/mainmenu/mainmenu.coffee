AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Construct.Loading.TV.MainMenu extends AM.Component
  @register 'LandsOfIllusions.Construct.Loading.TV.MainMenu'

  constructor: (@tv) ->
    super
  
    # Subscribe to user's activated characters.
    @_charactersSubscription = LOI.Character.activatedForCurrentUser.subscribe()
  
    @activatedCharacters = new ComputedField =>
      return unless user = Retronator.user()
  
      characterDocuments = _.filter user.characters, (character) =>
        character = LOI.Character.documents.findOne(character._id)
  
        character?.activated
  
      # Destroy previous character instances.
      character.destroy() for character in @_characters if @_characters
  
      @_characters = for characterDocument in characterDocuments
        new LOI.Character.Instance characterDocument._id
  
      @_characters

  onCreated: ->
    super

  events: ->
    super.concat
      'click .character': @onClickCharacter
      'click .new-character': @onClickNewCharacter

  onClickCharacter: (event) ->
    characterInstance = @currentData()

    @tv.fadeDeactivate =>
      LOI.adventure.loadCharacter characterInstance.id

  onClickNewCharacter: (event) ->
    @tv.switchToScreen @tv.screens.newLink
