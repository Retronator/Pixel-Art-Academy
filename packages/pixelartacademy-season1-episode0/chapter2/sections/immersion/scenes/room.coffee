LOI = LandsOfIllusions
HQ = Retronator.HQ
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class C2.Immersion.Room extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Immersion.Room'
  @location: -> HQ.LandsOfIllusions.Room

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/immersion/scenes/room.script'

  constructor: ->
    super

    @operator = new HQ.Actors.Operator

  things: -> [
    HQ.Actors.Operator if C2.Immersion.state('operatorState') is C2.Immersion.OperatorStates.InRoom
  ]

  # Script

  initializeScript: ->
    @setThings
      operator: @options.parent.operator

    @setCallbacks
      WaitToSit: (complete) =>
        @options.parent.state "waitToSit", true

        complete()

      Move: (complete) =>
        @options.parent.state 'waitToSit', false

        # Operator leaves back to the reception.
        C2.Immersion.state 'operatorState', C2.Immersion.OperatorStates.BackAtCounter

        complete()

      PlugIn: (complete) => HQ.LandsOfIllusions.Room.plugInCallback complete

  # Listener

  onEnter: (enterResponse) ->
    # Operator should talk when at location.
    @_operatorTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator
      return unless operator.ready()
      computation.stop()

      @script.setThings {operator}

      @startScript()

  onCommand: (commandResponse) ->
    return unless chair = LOI.adventure.getCurrentThing HQ.LandsOfIllusions.Room.Chair

    action = =>
      # If we're in the middle of the operator script, just continue on sit down.
      if @options.parent.state 'waitToSit'
        @startScript label: 'Sit'

      else
        # Otherwise start the self-start plug-in script.
        @startScript label: 'SelfStart'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.SitIn, chair.avatar]
      priority: 1
      action: => action()

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.SitDown]
      priority: 1
      action: => action()

  cleanup: ->
    @_operatorTalksAutorun?.stop()
