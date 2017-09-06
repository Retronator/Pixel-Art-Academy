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

      Meteor.setTimeout =>
        @listeners[0].startScript label: 'Alarm'
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

    # You can immerse after 6 minutes. It's 6 and not 5 so that when you look at the watch
    # right after the dialog ends, it shows 5 minutes. The units of returned value are seconds.
    6 * 60 - elapsedMilliseconds / 1000

  # Script

  initializeScript: ->
    @setThings
      operator: @options.listener.avatars.operator

    @setCallbacks
      ActivateHeadset: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).activate()
        complete()
              
      DeactivateHeadset: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).deactivate()
        complete()

      PlugIn: (complete) =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).enterConstruct complete

      AnalyzeAlarm: (complete) =>
        # Only start the alarm if you haven't already started the sync setup procedure.
        syncSetupStarted = _.nestedProperty LOI.adventure.gameState(), 'scripts.PixelArtAcademy.Season1.Episode0.Chapter2.Immersion.Room.SyncSetupProcedure'
        @ephemeralState().syncSetupStarted = syncSetupStarted

        complete()

  # Listener

  @avatars: ->
    operator: HQ.Actors.Operator

  onCommand: (commandResponse) ->
    section = @options.parent

    sync = LOI.adventure.getCurrentThing HQ.Items.Sync
    timeToImmersion = section.timeToImmersion()

    if sync and timeToImmersion
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], sync.avatar]
        priority: 1
        action: =>
          minutesLeft = Math.floor timeToImmersion / 60

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
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, @avatars.operator]]
        priority: 0.5
        action: =>
          @startScript label: 'TalkToOperator'
