LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.Store extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.Store'

  @location: -> HQ.Store

  @initialize()

  @listeners: ->
    super.concat [
      @StoreListener
    ]

  # Listener

  class @StoreListener extends LOI.Adventure.Listener

    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/store.script'
    ]

    class @Script extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.Store'
      @initialize()

    @initialize()

    onScriptsLoaded: ->
      @script = @scripts[@constructor.Script.id()]

    onAddToCartAttempt: (addToCartResponse) ->
      if addToCartResponse.catalogKey is PAA.PixelBoy.id()
        addToCartResponse.preventAdding()
        LOI.adventure.director.startScript @script, label: 'CantBuyPixelBoy'
