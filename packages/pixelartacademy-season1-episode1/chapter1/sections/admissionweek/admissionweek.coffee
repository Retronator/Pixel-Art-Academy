AB = Artificial.Base
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.AdmissionWeek extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionWeek'
  # applied: boolean if character has applied for admission week
  # applicationTime: game time when character applied
  @applyCharacter: new AB.Method name: "#{@id()}.applyCharacter"

  @scenes: -> [
  ]

  @initialize()

  active: ->
    # Admission week starts when the character has applied to the program.
    return false unless @state 'applied'

    super

  @finished: ->
    false
