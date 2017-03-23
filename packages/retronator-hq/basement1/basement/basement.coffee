LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Basement extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Basement'
  @url: -> 'retronator/basement'

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ basement reception"
  @shortName: -> "basement"
  @description: ->
    "
      You exit to the basement with a long hallway connecting to the Lands of Illusions virtual reality center in the 
      east. The north wall is made of glass and that lets you see into the Idea Garden, where Retro designs new 
      features. There is a small reception desk near the card-reader doors.
    "
  
  @initialize()

  @userProblemMessage = 'Retronator.HQ.LandsOfIllusions.userProblemMessage'

  things: -> [
    HQ.Actors.Operator
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Up}": HQ.Coworking

  @defaultScriptUrl: -> 'retronator_retronator-hq/basement1/basement/basement.script'

  initializeScript: ->
    @setCurrentThings
      operator: HQ.Actors.Operator

    @setCallbacks
      FirstTime: (complete) =>
        # Operator leaves to the hallway for you to follow.
        LOI.adventure.scriptHelpers.moveThingBetweenLocations
          thing: HQ.Actors.Operator
          sourceLocation: @
          destinationLocation: HQ.LandsOfIllusions.Hallway

        complete()

      Leave: (complete) =>
        LOI.adventure.goToLocation HQ.Chillout
        complete()

      AnalyzeUser: (complete) =>
        # Create a list of verified emails.
        user = Retronator.user()

        verifiedEmails = []

        if user.registered_emails
          for email in user.registered_emails
            verifiedEmails.push email.address if email.verified

        operatorDialog.ephemeralState().verifiedEmails = verifiedEmails
        complete()

      SendUserProblemMessage: (complete) =>
        operatorDialog.ephemeralState().sendUserProblemMessageError = false

        Meteor.method HQ.LandsOfIllusions.userProblemMessage, (error, result) =>
          if error
            operatorDialog.ephemeralState().sendUserProblemMessageError = true

          complete()

  onCommand: (commandResponse) ->
    return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
      action: => @startScript label: 'OperatorDialog'
