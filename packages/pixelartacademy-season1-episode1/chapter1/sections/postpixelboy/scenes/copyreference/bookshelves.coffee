LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.CopyReference.Bookshelves extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.CopyReference.Bookshelves'

  @location: -> HQ.Store.Bookshelves

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/copyreference/bookshelves.script'

  @intro: -> """
    You come to the bookshelves that house assorted books and a big collection of video games.
  """

  @initialize()

  things: ->
    corinneState = C1.PostPixelBoy.state 'corinneState'

    [
      HQ.Actors.Corinne if corinneState is C1.PostPixelBoy.CopyReference.CorinneStates.ByBookshelves
    ]

  # Script

  initializeScript: ->
    @setCurrentThings
      corinne: HQ.Actors.Corinne

    @setCallbacks
      Move: (complete) =>
        C1.PostPixelBoy.state 'corinneState', C1.PostPixelBoy.CopyReference.CorinneStates.BackInGalleryEast
        complete()

      ReceiveChallengeAsset: (complete) =>
        assetId = @ephemeralState 'assetId'

        unless assetId
          choice = @ephemeralState 'choice'

          assetsIds = [
            'MSHMVVVVVV'
            'MSHMDespotDungeons'
            'MSEMDespotDungeons'
            'MSEMLAbbayeDesMorts'
            'MSVMLuftrauser'
            'MBHMLouBagelsWaffleBar'
            'MBHMNetherWorld'
            'MBVMLuftrausers'
            'MBOMCityClickers'
            'CSHMCeleste'
            'CSEMHookLineAndThinker'
            'CSEMSuperCrateBox'
            'CBHMFez'
            'CBHMOwlboy'
            'CBHMCourierOfTheCrypts'
            'CBHMNYKRA'
            'CBEMSuperCrateBox'
            'CBEMIntoTheRift'
            'CBEMKingdomNewLands'
            'CBEMDontGiveUpACynicalTale'
            'CBVMIntoTheBreach'
            'CBVMSuperHydorah'
            'CBOMVirtuaVerse'
            'CBOMThimbleweedPark'
          ]

          possibleAssetIds = _.filter assetsIds, (assetId) => _.startsWith assetId, choice
          assetId = Random.choice possibleAssetIds

        challengeAssets = C1.Challenges.Drawing.PixelArtSoftware.state 'assets'
        challengeAssets ?= []
        id = "PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.#{assetId}"

        # Add the asset it's not already added.
        challengeAssets.push {id} unless _.find(challengeAssets, (asset) => asset.id is id)

        C1.Challenges.Drawing.PixelArtSoftware.state 'assets', challengeAssets

        complete()

  # Listener

  onEnter: (enterResponse) ->
    if C1.PostPixelBoy.state('corinneState') is C1.PostPixelBoy.CopyReference.CorinneStates.ByBookshelves
      enterResponse.overrideIntroduction =>
        @options.parent.translations()?.intro

    # Corinne should talk when at location.
    @_corinneTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne
      return unless corinne.ready()
      computation.stop()

      @startScript()

  cleanup: ->
    @_corinneTalksAutorun?.stop()
