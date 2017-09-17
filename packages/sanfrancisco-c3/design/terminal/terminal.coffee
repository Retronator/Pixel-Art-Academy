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

  onRendered: ->
    super

    # Show an alpha-state disclaimer.
    @showDialog
      message: "Agent design is in early prototype stage. Few avatar parts are available and things will change later on."
      cancelButtonText: "Understood"
