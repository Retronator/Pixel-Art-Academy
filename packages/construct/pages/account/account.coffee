AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct.Pages.Account extends AM.Component
  @register 'LandsOfIllusions.Construct.Pages.Account'

  constructor: (@app) ->
    super

  onCreated: ->
    super

    @subscribe 'LandsOfIllusions.Character.charactersForCurrentUser'

  onDestroyed: ->
    super

  # Helpers

  characters: ->
    user = RA.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    user?.characters

  dialogPreviewStyle: ->
    # Set the color to character's color.
    character = @currentData()

    color: "##{character.colorObject()?.getHexString()}"

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

  # Components

  class @CharacterName extends AM.DataInputComponent
    @register 'LandsOfIllusions.Construct.Pages.Account.CharacterName'

    load: ->
      @data()?.name

    save: (value) ->
      Meteor.call "LandsOfIllusions.Character.rename", @data()._id, value

    placeholder: ->
      @data()?.displayName()

  class @CharacterColorHue extends AM.DataInputComponent
    @register 'LandsOfIllusions.Construct.Pages.Account.CharacterColorHue'

    constructor: ->
      super

      @type = 'select'

    options: ->
      palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.systemPaletteNames.atari2600
      return unless palette

      value: i, name: ramp.name for ramp, i in palette.ramps

    load: ->
      @data()?.color?.hue or 0

    save: (value) ->
      # Change the hue part of color.
      Meteor.call "LandsOfIllusions.Character.changeColor", @data()._id, parseInt value

    placeholder: ->
      @load()

  class @CharacterColorShade extends AM.DataInputComponent
    @register 'LandsOfIllusions.Construct.Pages.Account.CharacterColorShade'

    constructor: ->
      super

      @type = 'select'

    options: ->
      value: i - 2, name: name for name, i in ['darkest', 'darker', 'normal', 'lighter', 'lightest']

    load: ->
      @data()?.color?.shade or 0

    save: (value) ->
      # Change the shade part of color.
      Meteor.call "LandsOfIllusions.Character.changeColor", @data()._id, null, parseInt value

    placeholder: ->
      @load()
