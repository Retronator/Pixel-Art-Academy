LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode0.Chapter3 extends LOI.Adventure.Chapter
  C3 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3'

  @fullName: -> "Making of a Cyborg"
  @number: -> 3

  @sections: -> [
    C3.Construct
  ]

  @scenes: -> [
    @Inventory
    @SecondStreet
    @FourthAndKing
    @MosconeCenter
  ]

  @initialize()

  constructor: ->
    super
