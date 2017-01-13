LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.LandsOfIllusions extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.LandsOfIllusions'
  @url: -> 'retronator/landsofillusions'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/locations/3rdfloor/landsofillusions/operator.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions reception"
  @shortName: -> "Lands of Illusions"
  @description: ->
    """
      You are in a reception room that could just as well be a spaceship deck.
      "Lands of Illusions" is written in big letters on the back wall.
      The operator, a muscular man with a friendly smile, greets you from behind the counter.
    """
  
  @initialize()
  
  @userProblemMessage = 'Retronator.HQ.Locations.LandsOfIllusions.userProblemMessage'

  constructor: ->
    super

  things: ->
    [HQ.Actors.Operator.id()]

  exits: ->
    exits = {}
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Chillout.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.LandsOfIllusions.Hallway.id()
    exits

  onScriptsLoaded: ->
    # Operator
    Tracker.autorun (computation) =>
      return unless operator = @things HQ.Actors.Operator.id()
      return unless operator.ready()
      computation.stop()

      operator.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          LOI.adventure.director.startScript operatorDialog

      operatorDialog = @scripts['Retronator.HQ.Locations.LandsOfIllusions.Scripts.Operator']

      operatorDialog.setActors
        operator: operator

      operatorDialog.setCallbacks
        FirstTime: (complete) =>
          # Operator leaves to the hallway for you to follow.
          LOI.adventure.scriptHelpers.moveThingBetweenLocations
            thing: HQ.Actors.Operator
            sourceLocation: @
            destinationLocation: HQ.Locations.LandsOfIllusions.Hallway

          complete()

        Leave: (complete) =>
          LOI.adventure.goToLocation HQ.Locations.Chillout
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

          Meteor.method HQ.Locations.LandsOfIllusions.userProblemMessage, (error, result) =>
            if error
              operatorDialog.ephemeralState().sendUserProblemMessageError = true

            complete()

      # Start the dialog automatically if you don't have permission to play or haven't been approved to play by the operator yet.
      user = Retronator.user()
      isPlayer = user.hasItem Retronator.Store.Items.CatalogKeys.PixelArtAcademy.PlayerAccess
      playApproved = operatorDialog.ephemeralState().PlayApproved

      LOI.adventure.director.startScript operatorDialog unless isPlayer and playApproved
