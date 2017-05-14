LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C2.Immersion extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Immersion'

  @scenes: -> [
    @Basement
    @LandsOfIllusions
    @Room
  ]
    
  @OperatorStates:
    InLandsOfIllusions: 'InLandsOfIllusions'
    InRoom: 'InRoom'
    BackAtCounter: 'BackAtCounter'

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/immersion/immersion.script'

  @initialize()

  @userProblemMessage = 'Retronator.HQ.LandsOfIllusions.userProblemMessage'

  constructor: ->
    super

    # Fire the alarm when immersion can begin.
    @autorun (computation) =>
      # Wait till time to immersion exists.
      return unless timeToImmersion = @timeToImmersion()
      computation.stop()

      # Don't do anything if alarm time has already passed.
      return if timeToImmersion < 0

      console.log "Starting alarm till immersion", timeToImmersion

      Meteor.setTimeout =>
        # Only start the script if you haven't already started 
        # the section the alarm is supposed to make you pay attention to.
        syncSetupStarted = _.nestedProperty LOI.adventure.gameState(), 'scripts.PixelArtAcademy.Season1.Episode0.Chapter2.Immersion.Room.RoomSyncSetupProcedure'

        console.log "ALARM", syncSetupStarted

        @listeners[0].startScript label: 'Alarm' unless syncSetupStarted
      ,
        timeToImmersion * 1000

  active: ->
    @requireFinishedSections C2.Intro

  @finished: ->
    # Immersion section ends when you complete the immersion script. Make sure you don't return undefined.
    @state('completed') is true

  # The time, in seconds, until the user can start immersion.
  timeToImmersion: ->
    # We require real life minutes to pass (and not game time, since
    # we want to allow the user to do other things on the internet).
    return unless redPillTime = @state('redPillTime')
    elapsedMilliseconds = Date.now() - redPillTime

    # You can immerse after 11 minutes. It's 11 and not 10 so that when you look at the watch
    # right after the dialog ends, it shows 10 minutes. The units of returned value are seconds.
    11 * 60 - elapsedMilliseconds / 1000

  # Script

  initializeScript: ->
    @setThings
      operator: @options.listener.avatars.operator

    @setCallbacks
      ActivateHeadset: (complete) => HQ.LandsOfIllusions.Room.activateHeadsetCallback complete
      PlugIn: (complete) => HQ.LandsOfIllusions.Room.plugInCallback complete
      DeactivateHeadset: (complete) => HQ.LandsOfIllusions.Room.deactivateHeadsetCallback complete

  # Listener

  @avatars: ->
    operator: HQ.Actors.Operator

  onCommand: (commandResponse) ->
    section = @options.parent

    if sync = LOI.adventure.getCurrentThing HQ.Items.Sync
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], sync.avatar]
        priority: 1
        action: =>
          minutesLeft = Math.floor section.timeToImmersion() / 60

          if minutesLeft < 0
            @startScript label: 'LookAtSyncTimeOver'

          else
            if minutesLeft is 0
              timeToImmersion = "less than a minute"

            else if minutesLeft is 1
              timeToImmersion = "one minute"

            else
              timeToImmersion = "#{minutesLeft} minutes"

            @script.ephemeralState 'timeToImmersion', timeToImmersion
            @startScript label: 'LookAtSyncTimeLeft'

    if section.state('operatorState') is C2.Immersion.OperatorStates.BackAtCounter and operatorLink = LOI.adventure.getCurrentThing HQ.Items.OperatorLink
      operator = operatorLink.operator

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, operator.avatar]]
        priority: 1
        action: =>
          @startScript label: 'TalkToOperator'
