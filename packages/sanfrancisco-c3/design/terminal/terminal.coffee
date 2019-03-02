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
  
  constructor: (@options = {}) ->
    super arguments...

  onCreated: ->
    super arguments...

    @screens =
      mainMenu: new @constructor.MainMenu @
      character: new @constructor.Character @
      avatarPart: new @constructor.AvatarPart @

    @switchToScreen @screens.mainMenu

    # Subscribe to all user's characters to see their designed status.
    LOI.Character.forCurrentUser.subscribe @

    # Subscribe to all character part templates.
    types = LOI.Character.Part.allAvatarPartTypeIds()

    # We already get all the templates for the current user, so we shouldn't return those.
    LOI.Character.Part.Template.forTypes.subscribe @, types,
      skipCurrentUsersTemplates: true
      onlyPublished: true
    
    @viewingAngle = new ReactiveField 0

  onRendered: ->
    super arguments...
    return

    # Show an alpha-state disclaimer.
    @showDialog
      message: "Agent design is in early prototype stage. Few avatar parts are available and things will change later on. Note that the editor includes pixel nudity."
      cancelButtonText: "Understood"

  onDestroyed: ->
    super arguments...

    @screens.character.destroy()
