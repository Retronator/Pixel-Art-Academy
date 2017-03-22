LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter2 extends LOI.Adventure.Chapter
  C2 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2'
  template: -> @constructor.id()

  @fullName: -> "Retronator HQ"
  @number: -> 2

  @url: -> 'chapter2'

  @sections: -> [
  ]

  @initialize()

  constructor: ->
    super

    # Move the player to caltrain on start.
    @autorun (computation) =>
      return unless LOI.adventure.gameState()

      movedToCaltrain = @state 'movedToCaltrain'
      return if movedToCaltrain

      LOI.adventure.goToLocation SanFrancisco.Soma.Caltrain
      @state 'movedToCaltrain', true

    # Finish intro.
    @autorun (computation) =>
      return unless LOI.adventure.gameState()

      introDone = @state 'introDone'
      return if introDone

  onRendered: ->
    unless @state 'introDone'
      # Run the intro script.
      @showChapterTitle
        onActivated: =>
          @state 'introDone', true

  fadeVisibleClass: ->
    'visible' unless @state 'introDone'
