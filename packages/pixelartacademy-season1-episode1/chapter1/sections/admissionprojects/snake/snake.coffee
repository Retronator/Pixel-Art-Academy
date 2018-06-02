LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.AdmissionProjects.Snake extends LOI.Adventure.Section
  # started: boolean if player has started this admission project
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake'

  @scenes: -> [
    @Workbench
  ]

  @initialize()

  # TODO: End the section when the user completes the project.
  @finished: -> false

  active: ->
    return false unless C1.Projects.Snake.readOnlyState 'activeProjectId'

    # Stop being active after we're finished (default).
    super
