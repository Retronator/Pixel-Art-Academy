LOI = LandsOfIllusions
Apartment = SanFrancisco.Apartment
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Intro.Studio extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Intro.Studio'

  @location: -> Apartment.Studio

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/intro/scenes/studio.script'

  @initialize()

  # Script
  
  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      StartDay: (complete) =>
        section = scene.options.parent
        chapter = section.options.parent

        chapter.showChapterTitle
          onActivated: =>
            complete()

            scene.state 'finished', true

  # Listener

  onEnter: (enterResponse) ->
    @startScript()
