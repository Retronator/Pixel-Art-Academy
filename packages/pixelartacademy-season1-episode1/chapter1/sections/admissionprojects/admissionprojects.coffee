LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.AdmissionProjects extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects'

  @scenes: -> [
  ]

  @initialize()

  @started: ->
    @requireFinishedSections C1.PixelBoy

  # TODO: End the section when the user finalizes admission.
