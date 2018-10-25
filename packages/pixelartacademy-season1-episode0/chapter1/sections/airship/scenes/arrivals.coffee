LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Airship.Arrivals extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Arrivals'

  @location: -> RS.AirportTerminal.Arrivals

  @initialize()

  things: ->
    [
      C1.Actors.Alex if @state 'alexPresent'
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/airship/scenes/arrivals.script'

  constructor: ->
    super arguments...

    @announcer = new RS.Items.Announcer

  initializeScript: ->
    scene = @options.parent
    announcer = scene.announcer

    @setThings {announcer}

  onEnter: (enterResponse) ->
    scene = @options.parent

    @startScript label: "AlexEnters" unless scene.state('alexPresent') or scene.state('alexLeft')

    return if scene.state('alexLeft')

    # Alex should talk when at location.
    @_alexTalksAutorun = @autorun (computation) =>
      return unless scene.state('alexPresent')

      return unless @scriptsReady()
      return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
      return unless alex.ready()
      computation.stop()

      @script.setThings {alex}

      @startScript label: "AlexTalks"

  onCommand: (commandResponse) ->
    return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
    @script.setThings {alex}

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.TalkTo], alex.avatar]
      priority: 1
      action: => @startScript label: 'InteractWithAlex'

  cleanup: ->
    @_alexTalksAutorun?.stop()
