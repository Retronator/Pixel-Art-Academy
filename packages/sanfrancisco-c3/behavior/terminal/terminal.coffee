LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Behavior.Terminal extends C3.Items.Terminal
  @id: -> 'SanFrancisco.C3.Behavior.Terminal'
  @url: -> 'c3/behavior-control/terminal'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "behavior terminal"
  @shortName: -> "terminal"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the computer where you can setup your character's properties.
    "

  @initialize()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  onCreated: ->
    super

    @screens =
      mainMenu: new @constructor.MainMenu @
      character: new @constructor.Character @
      personality: new @constructor.Personality @
      traits: new @constructor.Personality.Traits @

    @switchToScreen @screens.mainMenu

    # Subscribe to all user's characters to see their designed status.
    LOI.Character.forCurrentUser.subscribe @
