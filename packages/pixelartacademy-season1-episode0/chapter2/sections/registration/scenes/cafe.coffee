AB = Artificial.Base
LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class C2.Registration.Cafe extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Registration.Cafe'

  @location: -> HQ.Cafe

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/registration/scenes/cafe.script'

  @initialize()

  # Script

  initializeScript: ->
    # Link the placeholder to the main script.
    Tracker.autorun (computation) =>
      return unless cafe = LOI.adventure.getCurrentThing HQ.Cafe

      burraListener = cafe.getListener HQ.Cafe.BurraListener
      return unless burraListener.scriptsReady()
      computation.stop()

      # Find the second of main scripts' questions. We skip the
      # first one because it's the register fallback in the main script.
      burraScript = burraListener.scripts[HQ.Cafe.BurraListener.UserScript.id()]
      firstMainQuestion = burraScript.startNode.labels.MainQuestion.next.next

      # Find the last of this script's questions.
      lastQuestion = _.find @nodes, (node) => node.next is @startNode.labels.GeneralQuestionsPlaceholder

      # Link them together.
      lastQuestion.next = firstMainQuestion
    
    @setCurrentThings burra: HQ.Actors.Burra

    @setCallbacks
      SignInActive: (complete) =>
        LOI.adventure.saveGame =>
          Tracker.autorun (computation) =>
            # If user is logging out, wait until the userId becomes null (for example,
            # they logged in, but cancelled overwriting the save state, if it was already present).
            return if Meteor.loggingOut()

            # If user has signed in, wait until the game state has been loaded.
            return if Meteor.userId() and not LOI.adventure.gameStateSubscription().ready()
            computation.stop()

            console.log "Save game dialog has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", LOI.adventure.gameStateSubscription() if LOI.debug

            complete()

      ReceiveAccount: (complete) =>
        HQ.Items.Account.state 'inInventory', true

        complete()

      ReceiveKeycard: (complete) =>
        HQ.Items.Keycard.state 'inInventory', true

        complete()

      End: (complete) =>
        # Simply complete if this route can handle database states.
        if LOI.adventure.usesServerState()
          complete()
          return

        # We want to show a dialog informing the user to play on the main URL.
        dialog = new LOI.Components.Dialog
          message: "
                    You are now leaving #{location.host}. Your adventure will continue at
                    #{AB.Router.routes[LOI.Adventure.id()].host}. Thank you for registering!
                  "
          buttons: [
            text: "Continue"
          ]

        LOI.adventure.showActivatableModalDialog
          dialog: dialog
          callback: =>
            # Send the login token to the main adventure route where database state is allowed.
            url = AB.Router.createUrl LOI.Adventure, parameter1: 'signin'
            loginToken = localStorage.getItem 'Meteor.loginToken'

            AB.Router.postToUrl url, {loginToken}

  # Listener

  onCommand: (commandResponse) ->
    return unless burra = LOI.adventure.getCurrentThing HQ.Actors.Burra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, burra.avatar]
      priority: 1
      action: => @startScript()
