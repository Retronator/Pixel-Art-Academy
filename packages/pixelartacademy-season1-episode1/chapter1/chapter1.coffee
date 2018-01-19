AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode1.Chapter1 extends LOI.Adventure.Chapter
  # applied: boolean if character has applied for admission week
  # applicationTime: game date when character applied
  # accepted: boolean if character has started admission week
  # acceptedTime: boolean if character has started admission week
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1'

  @fullName: -> "Admission Week"
  @number: -> 1

  @sections: -> [
    @Intro
    @Waiting
    @PrePixelBoy
    @PixelBoy
  ]

  @scenes: -> [
    @Inbox
  ]

  @initialize()
  
  # Methods

  @applyCharacter: new AB.Method name: "#{@id()}.applyCharacter"

  constructor: ->
    super
