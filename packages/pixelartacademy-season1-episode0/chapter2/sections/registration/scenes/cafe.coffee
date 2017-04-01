LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class C2.Registration.Cafe extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Registration.Cafe'

  @location: -> HQ.Cafe

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/registration/scenes/cafe.script'

  initializeScript: ->
    @setCurrentThings burra: PAA.Cast.Burra

    @setCallbacks
      SignInActive: (complete) =>
        LOI.adventure.scriptHelpers.itemInteraction
          item: Retronator.HQ.Items.Wallet
          callback: =>
            console.log "Wallet has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", LOI.adventure.gameStateSubsription if LOI.debug

            Tracker.autorun (computation) =>
              # If user has signed in, wait also until the game state has been loaded.
              return if Meteor.userId() and not LOI.adventure.gameStateSubsription.ready()
              computation.stop()

              complete()

      CreateNewAccount: (complete) =>
        # Insert the current local storage state as the start of the database one.
        LOI.GameState.insertForCurrentUser LOI.adventure.gameState(), =>
          complete()

          # Now that the local state has been transferred, clear it for next player.
          LOI.adventure.clearLocalGameState()

      ReceiveAccount: (complete) =>
        HQ.Items.Account.state 'inInventory', true

        complete()

  onCommand: (commandResponse) ->
    return unless burra = LOI.adventure.getCurrentThing PAA.Cast.Burra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, burra.avatar]
      priority: 1
      action: => @startScript()
