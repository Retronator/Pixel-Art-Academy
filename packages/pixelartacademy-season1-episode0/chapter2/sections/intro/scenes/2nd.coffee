LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
Soma = SanFrancisco.Soma
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C2.Intro.SecondStreet extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Intro.SecondStreet'

  @location: -> Soma.SecondStreet

  @initialize()

  onExitAttempt: (exitResponse) ->
    # We display the chapter title when we go to the Cafe for the first time.
    return unless exitResponse.destinationLocationClass is HQ.Cafe

    scene = @options.parent

    # Show the chapter title, unless it's already showing (this method will be called the second time around when
    # animation has finished, so we need to let it through at that time).
    unless @_titleAnimationStarted or scene.state 'chapterTitleDone'

      @_titleAnimationStarted = true
      exitResponse.preventExit()

      scene.section.chapter.showChapterTitle
        onActivated: =>
          scene.state 'chapterTitleDone', true

          # Move on to the cafe.
          LOI.adventure.goToLocation HQ.Cafe

  cleanup: ->
    super arguments...

    @_conductorTalksAutorun?.stop()
