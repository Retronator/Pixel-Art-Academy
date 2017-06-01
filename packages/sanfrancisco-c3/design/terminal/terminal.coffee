LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Design.Terminal extends LOI.Adventure.Item
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

    @currentScreen = new ReactiveField @screens.mainMenu

  switchToScreen: (screen) ->
    @currentScreen screen
