LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.LandsOfIllusions.Room extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.LandsOfIllusions.Room'
  @url: -> 'retronator/landsofillusions/room'
  @region: -> HQ.LandsOfIllusions

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions immersion room"
  @shortName: -> "room"
  @description: ->
    "
      You enter a cosy room with a futuristic reclining chair located in the middle.
    "

  @defaultScriptUrl: -> 'retronator_retronator-landsofillusions/room/room.script'

  @initialize()

  things: -> [
    @constructor.Chair
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": HQ.LandsOfIllusions.Hallway
    "#{Vocabulary.Keys.Directions.Out}": HQ.LandsOfIllusions.Hallway

  isPrivate: -> true
  
  # Script

  initializeScript: ->
    @setCallbacks
      ActivateSync: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).startWithoutIntro()
        complete()

  # Listener
        
  onCommand: (commandResponse) ->
    return unless chair = LOI.adventure.getCurrentThing HQ.LandsOfIllusions.Room.Chair

    sitInChair = =>
      @startScript label: 'SelfStart'

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.SitIn, Vocabulary.Keys.Verbs.Use], chair.avatar]
      action: => sitInChair()

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.SitDown]
      action: => sitInChair()
