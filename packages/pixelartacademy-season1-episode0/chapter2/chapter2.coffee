LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter2 extends LOI.Adventure.Chapter
  C1 = @

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

  onRendered: ->
    unless @state 'introDone'
      # Run the intro script.
      @showChapterTitle
        toBeContinued: true

  fadeVisibleClass: ->
    'visible' unless @state 'introDone'
