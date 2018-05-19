LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.AdmissionProjects.Snake.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  things: ->
    things = []

    if projectId = C1.Projects.Snake.readOnlyState 'activeProjectId'
      things.push new C1.Projects.Snake projectId

    things
