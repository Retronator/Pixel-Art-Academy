LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Behavior extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Behavior'
  @url: -> 'c3/behavior-setup'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center Behavior Setup"
  @shortName: -> "Behavior"
  @description: ->
    "
      Behavior Setup is an isolated room at the east end of the manufacturing hall.
      Machine noises are replaced with hushing fans as supercomputers run machine learning algorithms and behavior
      simulations. Several workstations are lined up in the middle, with behavior assessment rooms in the background.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/behavior/behavior.script'

  @initialize()

  constructor: ->
    super arguments...

  destroy: ->
    super arguments...

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Design
    "#{Vocabulary.Keys.Directions.South}": C3.Hallway
    "#{Vocabulary.Keys.Directions.East}": C3.Stasis

  things: -> [
    C3.Behavior.Terminal
  ]

  # Script

  initializeScript: ->
    @setCallbacks
      UseTerminal: (complete) ->
        terminal = LOI.adventure.getCurrentThing C3.Behavior.Terminal
        LOI.adventure.goToItem terminal

        complete()

  # Listener

  onCommand: (commandResponse) ->
    if terminal = LOI.adventure.getCurrentThing C3.Behavior.Terminal
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], terminal.avatar]
        priority: 1
        action: =>
          @startScript label: 'UseTerminal'
