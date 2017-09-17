AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Construct.Loading.TV.MainMenu extends AM.Component
  @register 'LandsOfIllusions.Construct.Loading.TV.MainMenu'

  constructor: (@tv) ->
    super

  onCreated: ->
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

    # Which character is shown left-most. Allows to scroll through options.
    @firstCharacterOffset = new ReactiveField 0

    # Listen to changes in number of activated characters, so we can move the offset if needed.
    @autorun (computation) =>
      newIndex = Math.min @activatedCharacters().length - 2, @firstCharacterOffset()

      Tracker.nonreactive => @firstCharacterOffset newIndex

    @selectedCharacter = new ReactiveField null

    # Listen to changes in activated characters, so we can deselect a character that is not activated anymore.
    @autorun (computation) =>
      selectedCharacter = @selectedCharacter
      activatedCharacters = @activatedCharacters()

      unless selectedCharacter in activatedCharacters
        Tracker.nonreactive => @selectedCharacter null

  onRendered: ->
    @autorun (computation) =>
      offset = @firstCharacterOffset()

      @$('.character').eq(offset).velocity 'scroll',
        container: @$('.characters')
        axis: 'x'

  characterSelectedClass: ->
    character = @currentData()

    'selected' if @selectedCharacter() is character

  nextButtonVisibleClass: ->
    'visible' if @firstCharacterOffset() < @activatedCharacters().length - 2

  previousButtonVisibleClass: ->
    'visible' if @firstCharacterOffset() > 0

  events: ->
    super.concat
      'click .character': @onClickCharacter
      'click .screen': @onClickScreen
      'click .new-character': @onClickNewCharacter
      'click .sync-button': @onClickSyncButton
      'click .unlink-button': @onClickUnlinkButton
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickCharacter: (event) ->
    characterInstance = @currentData()

    @selectedCharacter characterInstance

  onClickScreen: (event) ->
    $target = $(event.target)
    return if $target.closest('.characters').length or $target.closest('.controls').length

    @selectedCharacter null

  onClickNewCharacter: (event) ->
    @tv.switchToScreen @tv.screens.newLink

  onClickSyncButton: (event) ->
    @tv.fadeDeactivate =>
      LOI.adventure.loadCharacter @selectedCharacter().id

  onClickUnlinkButton: (event) ->
    character = @selectedCharacter()

    # Double check that the user wants to be removed from their character.
    @tv.showDialog
      message: "Do you really want to unlink #{character.avatar.fullName()}? You will lose control of them and you cannot undo this action."
      confirmButtonText: "Unlink"
      confirmButtonClass: "danger-button"
      cancelButtonText: "Cancel"
      confirmAction: =>
        # Remove the user from the character.
        LOI.Character.removeUser character.id, (error) =>
          if error
            console.error error
            return

  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstCharacterOffset() - 1

    @firstCharacterOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @activatedCharacters().length - 2, @firstCharacterOffset() + 1

    @firstCharacterOffset newIndex
