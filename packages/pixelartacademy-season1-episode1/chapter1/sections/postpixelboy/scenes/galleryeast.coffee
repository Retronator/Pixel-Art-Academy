LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.GalleryEast extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.GalleryEast'

  @location: -> HQ.GalleryEast

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/galleryeast.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      corinne: HQ.Actors.Corinne

    @setCallbacks
      ReceiveChallengeAsset: (complete) =>
        assetId = @ephemeralState 'assetId'

        challengeAssets = C1.Challenges.Drawing.PixelArtSoftware.state 'assets'
        challengeAssets ?= []
        challengeAssets.push
          id: "PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.#{assetId}"

        C1.Challenges.Drawing.PixelArtSoftware.state 'assets', challengeAssets

        complete()

      BackToMainQuestions: (complete) =>
        # Hook back into the Reuben's main script.
        corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne
        corinne.listeners[0].startScript label: 'MainQuestions'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Corinne.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    # Prerequisite is that the player has selected a pixel art editor.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId') or PAA.PixelBoy.Apps.Drawing.state('externalSoftware')

    labels = [
      'PixelArtSoftwareChoice'
    ]

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next for label in labels
