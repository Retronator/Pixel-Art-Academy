LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Immigration.Customs extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Customs'

  @location: -> RS.AirportTerminal.Customs

  @initialize()

  things: ->
    [
      C1.Actors.Alex if @state 'alexPresent'
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/immigration/scenes/customs.script'

  onEnter: (enterResponse) ->
    @startScript label: "AlexEnters" unless @options.parent.state('alexPresent')

    # Alex should talk when at location.
    @_alexTalksAutorun = @autorun (computation) =>
      return unless @options.parent.state('alexPresent')

      return unless @scriptsReady()
      return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
      return unless alex.ready()
      computation.stop()

      @script.setThings {alex}

      @startScript label: "AlexTalks"

  onCommand: (commandResponse) ->
    alex = LOI.adventure.getCurrentThing C1.Actors.Alex
    @script.setThings {alex}

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.TalkTo], alex.avatar]
      priority: 1
      action: => @startScript label: 'InteractWithAlex'

  cleanup: ->
    @_alexTalksAutorun?.stop()

