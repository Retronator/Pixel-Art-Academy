LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Lobby extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Lobby'
  @url: -> 'c3/lobby'
  @region: -> SanFrancisco.Soma

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center lobby"
  @shortName: -> "lobby"
  @description: ->
    "
      The lobby of the Cyborg Construction Center, or C3 for short, is spacious and emits a high-tech vibe.
      Scientists in their white coats walk around with determination. 
      Customer service area continues to the east.
      Behind the receptionist on the north side lies a restricted area with Design Control and Manufacturing,
      as well a hallway that leads further into the facility northeast.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/lobby/lobby.script'

  @initialize()

  things: -> [
    C3.Actors.Receptionist
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": SanFrancisco.Soma.C3
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.C3
    "#{Vocabulary.Keys.Directions.North}": C3.Design
    "#{Vocabulary.Keys.Directions.Northeast}": C3.Hallway
    "#{Vocabulary.Keys.Directions.East}": C3.Service

  # Script
  
  initializeScript: ->
    @setCurrentThings
      receptionist: C3.Actors.Receptionist
      
  # Listener

  onCommand: (commandResponse) ->
    return unless receptionist = LOI.adventure.getCurrentThing C3.Actors.Receptionist

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, receptionist.avatar]
      action: => @startScript label: 'ReceptionistDialog'

  onExitAttempt: (exitResponse) ->
    return unless exitResponse.destinationLocationClass in [C3.Hallway, C3.Design]

    entryApproved = C3.Lobby.state 'entryApproved'
    return if entryApproved

    @startScript label: 'SneakBy'
    exitResponse.preventExit()
