LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Airship.Terminal extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Terminal'

  @location: -> RS.AirshipTerminal.Terminal

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/airship/scenes/terminal.script'

  constructor: ->
    @announcer = new RS.Items.Announcer

    super

  initializeScript: ->
    announcer = @options.parent.announcer

    @setThings {announcer}

  onEnter: (enterResponse) ->
    scene = @options.parent

    @autorun (computation) =>
      return unless timeToDeparture = scene.section.chapter.timeToAirshipDeparture()
      computation.stop()

      if timeToDeparture > 0
        @startScript label: "NotTooLate" unless @options.parent.state('announcementDone')

      else
        @startScript label: "TooLate"
