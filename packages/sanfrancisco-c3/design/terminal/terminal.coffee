LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Design.Terminal extends C3.Items.Terminal
  @id: -> 'SanFrancisco.C3.Design.Terminal'
  @url: -> 'c3/design-control/terminal'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "design terminal"
  @shortName: -> "terminal"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the computer where you can design your character.
    "

  @initialize()

  onCreated: ->
    super

    @screens =
      mainMenu: new @constructor.MainMenu @
      character: new @constructor.Character @
      avatarPart: new @constructor.AvatarPart @

    @switchToScreen @screens.mainMenu

    # Subscribe to all sprites used in user's templates for the full duration of the terminal being open.
    LOI.Assets.Sprite.forCharacterPartTemplatesOfCurrentUser.subscribe @

    # Subscribe to all character part templates and the sprites that they use.
    types = []

    addTypes = (type) =>
      # Go over all the properties of the type and add all sub-types.
      typeClass = _.nestedProperty LOI.Character.Part.Types, type

      for propertyName, property of typeClass.options.properties when property.options?.type?
        type = property.options.type

        types.push type
        addTypes type

    addTypes 'Avatar.Body'
    addTypes 'Avatar.Outfit'

    LOI.Character.Part.Template.forTypes.subscribe @, types
    LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.subscribe @, types

  onRendered: ->
    super

    # Show an alpha-state disclaimer.
    @showDialog
      message: "Agent design is in early prototype stage. Few avatar parts are available and things will change later on."
      cancelButtonText: "Understood"
