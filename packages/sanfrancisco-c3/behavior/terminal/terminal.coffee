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
    super arguments...

    @screens =
      mainMenu: new @constructor.MainMenu @
      character: new @constructor.Character @
      personality: new @constructor.Personality @
      traits: new @constructor.Personality.Traits @
      activities: new @constructor.Activities @
      environment: new @constructor.Environment @
      people: new @constructor.People @
      perks: new @constructor.Perks @

    @switchToScreen @screens.mainMenu

  onRendered: ->
    super arguments...

    # Show an alpha-state disclaimer.
    @showDialog
      message: "Behavior setup is in early prototype stage. Most attributes will not have effect on gameplay until later in development."
      cancelButtonText: "Understood"
