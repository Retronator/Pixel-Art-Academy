LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Design extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Design'
  @url: -> 'c3/design-control'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center Design Control"
  @shortName: -> "Design"
  @description: ->
    "
      The Design Control area overlooks a big factory hall with numerous assembly line stations.
      A terminal with various design charts is available to use.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/design/design.script'

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": C3.Lobby
    "#{Vocabulary.Keys.Directions.East}": C3.Behavior

  things: -> [
    C3.Actors.DrShelley
    C3.Design.Terminal
  ]

  # Script

  initializeScript: ->
    @setCurrentThings
      drshelley: C3.Actors.DrShelley

  # Listener

  onCommand: (commandResponse) ->
    if drShelley = LOI.adventure.getCurrentThing C3.Actors.DrShelley
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, drShelley.avatar]
        action: => @startScript label: 'ShelleyDialog'

    if terminal = LOI.adventure.getCurrentThing C3.Design.Terminal
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], terminal.avatar]
        priority: 1
        action: =>
          LOI.adventure.goToItem terminal
