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

  @avatars: ->
    schedule: RS.AirshipTerminal.Terminal.Schedule

  onEnter: (enterResponse) ->
    scene = @options.parent
    chapter = scene.section.chapter

    @autorun (computation) =>
      return unless timeToDeparture = chapter.timeToAirshipDeparture()
      computation.stop()

      if timeToDeparture > 0
        @startScript label: "NotTooLate" unless @options.parent.state('announcementDone')

        # Start waiting for time out
        Tracker.nonreactive =>
          @_departureAutorun = @autorun (computation) =>
            return if chapter.timeToAirshipDeparture() > 0
            computation.stop()

            @startScript label: "TooLateAtLocation"

      else
        @startScript label: "TooLate"

  onCommand: (commandResponse) ->
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, @avatars.schedule]
      priority: 1
      action: =>
        scene = @options.parent
        minutesLeft = Math.floor scene.section.chapter.timeToAirshipDeparture() / 60

        if minutesLeft <= 0
          timeToDeparture = "less than a minute"

        else if minutesLeft is 1
          timeToDeparture = "one minute"

        else
          timeToDeparture = "#{minutesLeft} minutes"

        @script.ephemeralState 'timeToDeparture', timeToDeparture
        @startScript label: 'LookAtSchedule'

  cleanup: ->
    @_departureAutorun.stop()
