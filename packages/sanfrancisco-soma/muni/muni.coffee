LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Muni extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Muni'
  @url: -> 'sf/muni'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "T Third Street Muni train"
  @shortName: -> "Muni train"
  @description: ->
    "
      You board the line T Muni train.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-soma/muni/muni.script'

  @initialize()

  @setLocation: (location) ->
    return unless LOI.adventure.gameState()

    newLocationId = if location then _.thingId(location) else null

    @state 'locationId', newLocationId

  @getLocation: ->
    return unless locationId = @state 'locationId'

    LOI.Adventure.Location.getClassForId locationId

  exits: ->
    return unless location = @constructor.getLocation()

    "#{Vocabulary.Keys.Directions.Out}": location

  # Script

  initializeScript: ->
    @setCallbacks
      Exit: (complete) ->
        LOI.adventure.goToLocation Soma.Muni.getLocation()

  # Listener

  onEnter: (enterResponse) ->
    # Ask the player where they want to go as soon as they board.
    @autorun (computation) =>
      return unless @scriptsReady()
      computation.stop()

      @startScript()
