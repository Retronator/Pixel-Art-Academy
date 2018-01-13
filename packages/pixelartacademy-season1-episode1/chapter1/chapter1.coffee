LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode1.Chapter1 extends LOI.Adventure.Chapter
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1'

  @fullName: -> "Admission Week"
  @number: -> 1

  @sections: -> [
    @Intro
    @AdmissionWeek
  ]

  @scenes: -> [
    @Inbox
  ]

  @initialize()

  constructor: ->
    super
