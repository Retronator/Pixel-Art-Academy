LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class C3.Construct.Loading extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Construct.Loading'

  @location: -> LOI.Construct.Loading

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter3/sections/construct/scenes/loading.script'

  @initialize()

  constructor: ->
    super

    @operator = new HQ.Actors.Operator

  things: -> [
    LOI.Construct.Actors.Captain
  ]

  # Script

  initializeScript: ->
    @setCurrentThings
      captain: LOI.Construct.Actors.Captain

    @setThings
      operator: @options.parent.operator

    @setCallbacks
      ShowTitle: (complete) =>
        @options.parent._showChapterTitle()
        complete()

      C3: (complete) =>
        LOI.adventure.goToLocation LOI.Construct.C3.Entrance
        complete()

      Exit: (complete) =>
        LOI.adventure.goToLocation Retronator.HQ.LandsOfIllusions.Room
        LOI.adventure.goToTimeline PAA.TimelineIds.RealLife
        complete()

  _showChapterTitle: ->
    # Only allow one call to this.
    return if @_chapterTitleShown
    @_chapterTitleShown = true

    @section.chapter.showChapterTitle
      toBeContinued: true

  # Listener

  onEnter: (enterResponse) ->
    console.log "enter"

    # Captain should talk when at location.
    @_captainTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless captain = LOI.adventure.getCurrentThing LOI.Construct.Actors.Captain
      return unless captain.ready()
      computation.stop()

      @script.setThings {captain}

      @startScript()

  cleanup: ->
    @_captainTalksAutorun?.stop()

  onCommand: (commandResponse) ->
    return unless captain = LOI.adventure.getCurrentThing LOI.Construct.Actors.Captain
    return unless tv = LOI.adventure.getCurrentThing LOI.Construct.Loading.TV

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, captain.avatar]
      action: => @startScript label: 'MainDialog'

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], tv.avatar]
      priority: 1
      action: => @startScript label: 'LookAtTV'
