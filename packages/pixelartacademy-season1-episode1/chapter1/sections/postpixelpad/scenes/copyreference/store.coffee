LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelPad.CopyReference.Store extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelPad.CopyReference.Store'

  @location: -> HQ.Store

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelpad/scenes/copyreference/store.script'

  @translations: ->
    corinneIntro: """
      You walk with Corinne past store shelves.
    """

  @initialize()

  things: ->
    corinneState = C1.PostPixelPad.state 'corinneState'

    [
      HQ.Actors.Corinne if corinneState is C1.PostPixelPad.CopyReference.CorinneStates.InStore
    ]

  # Script

  initializeScript: ->
    @setCurrentThings
      corinne: HQ.Actors.Corinne

    @setCallbacks
      Move: (complete) =>
        C1.PostPixelPad.state 'corinneState', C1.PostPixelPad.CopyReference.CorinneStates.ByBookshelves
        complete()

  # Listener

  onEnter: (enterResponse) ->
    return unless C1.PostPixelPad.state('corinneState') is C1.PostPixelPad.CopyReference.CorinneStates.InStore

    enterResponse.overrideIntroduction =>
      @options.parent.translations()?.corinneIntro

    # Corinne should talk when at location.
    @_corinneTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne
      return unless corinne.ready()
      computation.stop()

      @script.setThings {corinne}

      @startScript()

  cleanup: ->
    @_corinneTalksAutorun?.stop()
