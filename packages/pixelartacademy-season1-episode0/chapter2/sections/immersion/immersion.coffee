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
    IntroDone: 'IntroDone'
    BackAtCounter: 'BackAtCounter'

  @avatars: ->
    sync: HQ.Items.Sync

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

  # The time, in seconds, until the user can start immersion.
  timeToImmersion: ->
    # We require real life minutes to pass (and not game time, since
    # we want to allow the user to do other things on the internet).
    return unless redPillTime = @state('redPillTime')
    elapsedMiliseconds = Date.now() - redPillTime

    # You can immerse after 5 minutes. The units of returned value are seconds.
    5 * 60 - elapsedMiliseconds / 1000

  # Listener

  onCommand: (commandResponse) ->
    section = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, @avatars.sync]
      priority: 1
      action: =>
        minutesLeft = Math.floor section.timeToImmersion() / 60

        if minutesLeft < 0
          @startScript label: 'LookAtSyncTimeOver'

        else
          if minutesLeft = 0
            timeToDeparture = "less than a minute"

          else if minutesLeft is 1
            timeToDeparture = "one minute"

          else
            timeToDeparture = "#{minutesLeft} minutes"

          @script.ephemeralState 'timeToDeparture', timeToDeparture
          @startScript label: 'LookAtSyncTimeLeft'
