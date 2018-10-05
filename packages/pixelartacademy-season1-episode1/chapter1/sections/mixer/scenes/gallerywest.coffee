LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest'

  @location: ->
    HQ.GalleryWest

  @intro: -> """
    You enter a big gallery space that is holding a gathering.
    You recognize some people from the HQ, others seem to be recent visitors like yourself.
  """

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest.script'

  @initialize()

  things: -> [
    HQ.Actors.Shelley
    @constructor.Retro
    HQ.Actors.Alexandra
    HQ.Actors.Reuben
  ]
    
  # Script

  initializeScript: ->
    @setCurrentThings
      retro: HQ.Actors.Retro

  # Listener

  onEnter: (enterResponse) ->
    # Retro should talk when at location.
    @_retroTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
      return unless retro.ready()
      computation.stop()

      @script.setThings {retro}

      @startScript label: 'RetroIntro'

  cleanup: ->
    @_retroTalksAutorun?.stop()

  class @Retro extends HQ.Actors.Retro
    @initialize()
    @descriptiveName: -> "#{super} He is sitting behind a table with ![markers](pick up marker) and name tag ![stickers](pick up stickers)."
