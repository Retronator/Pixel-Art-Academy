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
    super arguments...

    @operator = new HQ.Actors.Operator

  things: -> [
    LOI.Construct.Actors.Captain
  ]

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      captain: LOI.Construct.Actors.Captain

    @setThings
      operator: scene.operator

    @setCallbacks
      ShowTitle: (complete) =>
        scene._showChapterTitle()
        complete()

  _showChapterTitle: ->
    # Only allow one call to this.
    return if @_chapterTitleShown
    @_chapterTitleShown = true

    @section.chapter.showChapterTitle()

  # Listener

  onEnter: (enterResponse) ->
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

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, captain.avatar]
      action: => @startScript label: 'MainDialog'
