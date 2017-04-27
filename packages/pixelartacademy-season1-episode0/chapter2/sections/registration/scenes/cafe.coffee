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
    @setCurrentThings burra: HQ.Actors.Burra

    @setCallbacks
      SignInActive: (complete) =>
        LOI.adventure.saveGame =>
          # If user has signed in, wait until the game state has been loaded.
          Tracker.autorun (computation) =>
            return if Meteor.userId() and not LOI.adventure.gameStateSubsription.ready()
            computation.stop()

            console.log "Save game dialog has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", LOI.adventure.gameStateSubsription if LOI.debug

            complete()

      ReceiveAccount: (complete) =>
        HQ.Items.Account.state 'inInventory', true

        complete()

      ReceiveKeycard: (complete) =>
        HQ.Items.Keycard.state 'inInventory', true

        complete()

  onCommand: (commandResponse) ->
    return unless burra = LOI.adventure.getCurrentThing HQ.Actors.Burra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, burra.avatar]
      priority: 1
      action: => @startScript()
