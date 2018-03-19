LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Service.Terminal extends C3.Items.Terminal
  @id: -> 'SanFrancisco.C3.Service.Terminal'
  @url: -> 'c3/customer-service/terminal'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "customer terminal"
  @shortName: -> "terminal"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the computer where you can order a character.
    "

  @initialize()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()

      # Start the Panzer script if any character was made during this use.
      if @createdCharacter
        service = LOI.adventure.currentLocation()
        service.listeners[0].startScript label: 'Sync'
    ,
      500

  onCreated: ->
    super

    @screens =
      mainMenu: new @constructor.MainMenu @
      character: new @constructor.Character @
      modelSelection: new @constructor.ModelSelection @

    @switchToScreen @screens.mainMenu

    # Subscribe to all user's characters to see their designed status.
    LOI.Character.forCurrentUser.subscribe @
    
    @createdCharacter = false
