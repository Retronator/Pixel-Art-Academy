LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.LandsOfIllusions.Room extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.LandsOfIllusions.Room'
  @url: -> 'retronator/landsofillusions/room'

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions virtual reality room"
  @shortName: -> "room"
  @description: ->
    "
      You enter a cosy room with a big futuristic reclining chair located in the middle.
      A virtual reality headset is suspended from the ceiling and connected to a computer terminal on the side.
    "

  @defaultScriptUrl: -> 'retronator_retronator-landsofillusions/room/room.script'

  @initialize()

  constructor: ->
    super
    
    @operator = new HQ.Actors.Operator

  things: -> [
    @constructor.Chair
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": HQ.LandsOfIllusions
    "#{Vocabulary.Keys.Directions.Out}": HQ.LandsOfIllusions

  @plugInCallback: (complete) =>
    # Start Lands of Illusions VR Experience.
    LOI.adventure.goToItem HQ.LandsOfIllusions.Room.Chair

    complete()

  # Script

  initializeScript: ->
    operator = @options.parent.operator

    @setThings
      operator: operator
      
    @setCallbacks
      PlugIn: (complete) => HQ.LandsOfIllusions.Room.plugInCallback complete

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
