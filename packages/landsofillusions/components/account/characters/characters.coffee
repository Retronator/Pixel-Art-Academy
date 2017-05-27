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

  onCreated: ->
    super

    @subscribe 'LandsOfIllusions.Character.charactersForCurrentUser'

  characters: ->
    user = RA.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    return unless characters = user?.characters
    
    for character in characters
      character.refresh()
      
    characters

  emptyLines: ->
    charactersCount = @characters()?.length or 0
    return if charactersCount >= 5

    # Return an array with enough elements to pad the characters list to 5 rows.
    '' for i in [charactersCount...5]

  dialogPreviewStyle: ->
    # Set the color to character's color.
    character = @currentData()

    color: "##{character.avatar.colorObject()?.getHexString()}"

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
    LOI.switchCharacter characterId

  onClickUnloadCharacter: (event) ->
    LOI.switchCharacter null

  class @CharacterColorHue extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.Characters.CharacterColorHue'

    constructor: ->
      super

      @type = 'select'

    options: ->
      return unless palette = LOI.palette()

      value: rampIndex, name: ramp.name for ramp, rampIndex in palette.ramps

    load: ->
      @data()?.avatarData?.color?.hue or 0

    save: (value) ->
      # Change the hue part of color.
      Meteor.call "LandsOfIllusions.Character.changeColor", @data()._id, parseInt value

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
      @data()?.avatarData?.color?.shade or 0

    save: (value) ->
      # Change the shade part of color.
      Meteor.call "LandsOfIllusions.Character.changeColor", @data()._id, null, parseInt value

    placeholder: ->
      @data()?.displayName()
