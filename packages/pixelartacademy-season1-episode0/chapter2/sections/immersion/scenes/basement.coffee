LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
RA = Retronator.Accounts

Vocabulary = LOI.Parser.Vocabulary

class C2.Immersion.Basement extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Immersion.Basement'
  @location: -> HQ.Basement

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/immersion/scenes/basement.script'

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: -1

    @subscribe RA.User.registeredEmailsForCurrentUser

  things: -> [
    HQ.Actors.Operator unless C2.Immersion.state 'operatorState'
  ]

  removedThings: ->
    # Because operator generally appears in the basement, we need to remove him when some of these scenes run.
    operatorState = C2.Immersion.state 'operatorState'

    [
      HQ.Actors.Operator if operatorState in [C2.Immersion.OperatorStates.InLandsOfIllusions, C2.Immersion.OperatorStates.InRoom]
    ]

  # Script

  initializeScript: ->
    @setCurrentThings
      operator: HQ.Actors.Operator

    @setCallbacks
      Move: (complete) =>
        # Operator leaves to the hallway for you to follow.
        C2.Immersion.state 'operatorState', C2.Immersion.OperatorStates.InLandsOfIllusions

        complete()

      AnalyzeUser: (complete) =>
        # Create a list of verified emails.
        user = Retronator.user()

        verifiedEmails = []

        if user.registered_emails
          for email in user.registered_emails
            verifiedEmails.push email.address if email.verified

        @ephemeralState().verifiedEmails = verifiedEmails
        complete()

      SendUserProblemMessage: (complete) =>
        @ephemeralState().sendUserProblemMessageError = false

        Meteor.call C2.Immersion.userProblemMessage, (error, result) =>
          if error
            @ephemeralState().sendUserProblemMessageError = true

          complete()

  # Listener

  onCommand: (commandResponse) ->
    return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
      priority: 1
      action: => @startScript label: 'OperatorDialog'

  onExitAttempt: (exitResponse) ->
    return unless exitResponse.destinationLocationClass is HQ.LandsOfIllusions

    hasInteracted = C2.Immersion.state 'operatorState'
    return if hasInteracted

    @startScript label: 'SneakBy'
    exitResponse.preventExit()
