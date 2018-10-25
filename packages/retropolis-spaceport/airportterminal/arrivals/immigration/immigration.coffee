LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Immigration extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration'
  @url: -> 'spaceport/immigration'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "immigration checkpoint"
  @shortName: -> "immigration"
  @description: ->
    "
      You are in front of the immigration checkpoint where people
      are waiting for their turn at the automated immigration terminals.
      The airport terminal concourse in the west leads further towards the gates.
    "
  
  @initialize()

  constructor: ->
    super arguments...
    @announcer = new RS.Items.Announcer

  things: -> [
    RS.AirportTerminal.Immigration.Terminal
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Concourse

  @defaultScriptUrl: -> 'retronator_retropolis-spaceport/airportterminal/arrivals/immigration/immigration.script'

  initializeScript: ->
    announcer = @options.parent.announcer

    @setThings {announcer}

  onEnter: (commandResponse) ->
    # Start the announcer.
    @startScript label: "PlayAnnouncement"

    # Wait for player to have their passport ready before terminal says it's available.
    @_terminalAvailableAutorun = @autorun (computation) =>
      passport = LOI.adventure.getCurrentThing PixelArtAcademy.Season1.Episode0.Chapter1.Items.Passport
      return unless passport
      computation.stop()

      @startScript label: "TerminalAvailable"

  cleanup: ->
    @_terminalAvailableAutorun.stop()
