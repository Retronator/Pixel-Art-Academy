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
    super arguments...

    @operator = new HQ.Actors.Operator

  things: ->
    operatorInRoom = C2.Immersion.state('operatorState') is C2.Immersion.OperatorStates.InRoom

    [
      HQ.Actors.Operator if operatorInRoom
      C2.Items.VideoTablet if operatorInRoom
    ]

  # Script

  initializeScript: ->
    @setThings
      operator: @options.parent.operator

    @setCallbacks
      WaitToSit: (complete) =>
        @options.parent.state "waitToSit", true

        complete()
        
      RedPillStart: (complete) =>
        @options.parent.section.state 'redPillTime', Date.now()
        
        complete()
        
      GetTimeToImmersion: (complete) =>
        @ephemeralState().timeToImmersion = @options.parent.section.timeToImmersion()

        complete()

      VideoDisplay: (complete) =>
        LOI.adventure.scriptHelpers.itemInteraction
          item: C2.Items.VideoTablet
          callback: => complete()

      Move: (complete) =>
        @options.parent.state 'waitToSit', false

        # Operator leaves back to the reception.
        C2.Immersion.state 'operatorState', C2.Immersion.OperatorStates.BackAtCounter

        complete()

      ActivateHeadset: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).activate()
        complete()

      DeactivateHeadset: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).deactivate()
        complete()

      FirstImmersion: (complete) =>
        scene = @options.parent
        scene.section.listeners[0].startScript label: 'FirstImmersion'

        complete()

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
    sitAction = =>
      # If we're in the middle of the operator script, just continue on sit down.
      if @options.parent.state 'waitToSit'
        @startScript label: 'Sit'

      else
        # Otherwise start the self-start script.
        @startScript label: 'SelfStart'

    if chair = LOI.adventure.getCurrentThing HQ.LandsOfIllusions.Room.Chair
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.SitIn, Vocabulary.Keys.Verbs.Use], chair.avatar]
        priority: 1
        action: sitAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.SitDown]
        priority: 1
        action: sitAction

    if operator = LOI.adventure.getCurrentThing HQ.Actors.Operator
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
        action: sitAction

  cleanup: ->
    @_operatorTalksAutorun?.stop()
