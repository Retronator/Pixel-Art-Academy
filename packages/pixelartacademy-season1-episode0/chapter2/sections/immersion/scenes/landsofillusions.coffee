LOI = LandsOfIllusions
HQ = Retronator.HQ
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class C2.Immersion.LandsOfIllusions extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Immersion.LandsOfIllusions'
  @location: -> HQ.LandsOfIllusions.Hallway

  @translations: ->
    intro: "
      You follow Panzer into a hallway of the VR center with many doors along its sides.
    "

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/immersion/scenes/landsofillusions.script'

  constructor: ->
    super arguments...

  things: -> [
    HQ.Actors.Operator if C2.Immersion.state('operatorState') is C2.Immersion.OperatorStates.InLandsOfIllusions
  ]

  # Script

  initializeScript: ->
    @setCurrentThings
      operator: HQ.Actors.Operator

    @setCallbacks
      Move: (complete) =>
        # Operator leaves to the room for you to follow.
        C2.Immersion.state 'operatorState', C2.Immersion.OperatorStates.InRoom

        complete()

  # Listener

  onEnter: (enterResponse) ->
    if C2.Immersion.state('operatorState') is C2.Immersion.OperatorStates.InLandsOfIllusions
      enterResponse.overrideIntroduction =>
        @options.parent.translations()?.intro

    # Operator should talk when at location.
    @_operatorTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator
      return unless operator.ready()
      computation.stop()

      @script.setThings {operator}

      @startScript()

  cleanup: ->
    @_operatorTalksAutorun?.stop()
