AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Characters extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Characters'
  @url: -> 'characters'
  @displayName: -> 'Characters'
    
  @initialize()

  constructor: ->
    super

    # We want to be able to set the selected user even before the page gets rendered,
    # so that it's already displaying it when the account is turned to the characters page.
    @selectedCharacterId = new ReactiveField null

  onCreated: ->
    super

    LOI.Character.forCurrentUser.subscribe @

    @selectedCharacter = new ComputedField =>
      LOI.Character.documents.findOne @selectedCharacterId()

    nameInputOptions =
      addTranslationText: => @translation "Add language variant"
      removeTranslationText: => @translation "Remove language variant"
      newTranslationLanguage: ''

    @fullNameInput = new LOI.Components.TranslationInput _.extend {}, nameInputOptions,
      placeholderText: => LOI.Character.Avatar.noNameTranslation()
      placeholderInTargetLanguage: true
      onTranslationInserted: (languageRegion, value) =>
        LOI.Character.updateName @selectedCharacterId(), languageRegion, value

      onTranslationUpdated: (languageRegion, value) =>
        LOI.Character.updateName @selectedCharacterId(), languageRegion, value

        # Return true to prevent the default update to be executed.
        true
        
  renderFullNameInput: ->
    @fullNameInput.renderComponent @currentComponent()

  characters: ->
    user = Retronator.user()
    return unless user?.characters

    for character in user.characters
      LOI.Character.documents.findOne character._id

  emptyLines: ->
    charactersCount = @characters()?.length or 0
    return if charactersCount >= 5

    # Return an array with enough elements to pad the characters list to 5 rows.
    '' for i in [charactersCount...5]

  dialogPreviewStyle: ->
    # Set the color to character's color.
    character = @currentData()
    color = LOI.Avatar.colorObject character.avatar.color

    color: "##{color.getHexString()}"

  showLoadButtonClass: ->
    character = @currentData()

    # We need to show the load button unless this is the current character.
    'show-load-button' if character._id isnt LOI.characterId()

  # Events

  events: ->
    super.concat
      'click .new-character': @onClickNewCharacter
      'click .load-character': @onClickLoadCharacter
      'click .unload-character': @onClickUnloadCharacter

  onClickNewCharacter: (event) ->
    Meteor.call 'LandsOfIllusions.Character.insert', Meteor.userId()

  onClickLoadCharacter: (event) ->
    characterId = @currentData()._id
    @selectedCharacterId characterId

  onClickUnloadCharacter: (event) ->
    @selectedCharacterId null

  class @CharacterColorHue extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.Characters.CharacterColorHue'

    constructor: ->
      super

      @type = 'select'

    options: ->
      return unless palette = LOI.palette()

      value: rampIndex, name: ramp.name for ramp, rampIndex in palette.ramps

    load: ->
      @data()?.avatar?.color?.hue or 0

    save: (value) ->
      # Change the hue part of color.
      LOI.Character.updateColor @data()._id, parseInt value

    placeholder: ->
      @data()?.displayName()

  class @CharacterColorShade extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.Characters.CharacterColorShade'

    constructor: ->
      super

      @type = 'select'

    options: ->
      value: shadeIndex - 2, name: name for name, shadeIndex in ['darkest', 'darker', 'normal', 'lighter', 'lightest']

    load: ->
      @data()?.avatar?.color?.shade or 0

    save: (value) ->
      # Change the shade part of color.
      LOI.Character.updateColor @data()._id, null, parseInt value

    placeholder: ->
      @data()?.displayName()
