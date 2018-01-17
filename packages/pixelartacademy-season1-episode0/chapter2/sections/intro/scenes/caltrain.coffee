LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
Soma = SanFrancisco.Soma
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C2.Intro.Caltrain extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Intro.Caltrain'

  @location: -> Soma.Caltrain

  @translations: ->
    intro: "You wake up inside the train carriage you were taking into the city."

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/intro/scenes/caltrain.script'

  @avatars: ->
    prospectus: HQ.Items.Prospectus

  @initialize()

  description: ->
    @translations()?.intro unless @state 'talkDone'

  things: ->
    [
      C2.Actors.Conductor
    ]

  initializeScript: ->
    @setCurrentThings conductor: C2.Actors.Conductor

  onEnter: (enterResponse) ->
    scene = @options.parent

    return if scene.state('talkDone')

    # Conductor should talk when at location.
    @_conductorTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless conductor = LOI.adventure.getCurrentThing C2.Actors.Conductor
      return unless conductor.ready()
      computation.stop()

      @script.setThings {conductor}

      @startScript()

  onCommand: (commandResponse) ->
    return unless conductor = LOI.adventure.getCurrentThing C2.Actors.Conductor

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, conductor.avatar]
      action: => @startScript label: "ConductorTalk"

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.GiveTo, Vocabulary.Keys.Verbs.ShowTo], @avatars.prospectus, conductor.avatar]
      action: => @startScript label: "ShowProspectus"

  cleanup: ->
    super

    @_conductorTalksAutorun?.stop()
