LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.CopyReference.GalleryEast extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.CopyReference.GalleryEast'

  @location: -> HQ.GalleryEast

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/copyreference/galleryeast.script'

  @initialize()

  removeThings: ->
    # Because Corinne generally appears in the gallery east, we need to remove her when some of these scenes run.
    corinneState = C1.PostPixelBoy.state 'corinneState'

    [
      HQ.GalleryEast.Corinne if corinneState in [C1.PostPixelBoy.CopyReference.CorinneStates.InGalleryWest, C1.PostPixelBoy.CopyReference.CorinneStates.InStore, C1.PostPixelBoy.CopyReference.CorinneStates.ByBookshelves]
    ]

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      corinne: HQ.Actors.Corinne

    @setCallbacks
      CorinneLeaves: (complete) =>
        C1.PostPixelBoy.state 'corinneState', C1.PostPixelBoy.CopyReference.CorinneStates.InGalleryWest
        complete()

      CorinneLeavesAgain: (complete) =>
        C1.PostPixelBoy.state 'corinneState', C1.PostPixelBoy.CopyReference.CorinneStates.ByBookshelves
        complete()

      Return: (complete) =>
        # Hook back into Corinne's main script.
        corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne
        corinne.listeners[0].startScript label: 'MainQuestions'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Corinne.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    # Prerequisite is that the player has selected a pixel art editor.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId') or PAA.PixelBoy.Apps.Drawing.state('externalSoftware')

    if C1.PostPixelBoy.state('corinneState') is C1.PostPixelBoy.CopyReference.CorinneStates.BackInGalleryEast
      choiceLabel = 'AnotherSpriteChoice'

    else
      choiceLabel = 'PixelArtSoftwareChoice'

    choicePlaceholderResponse.addChoice @script.startNode.labels[choiceLabel].next
