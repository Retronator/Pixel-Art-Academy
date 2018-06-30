LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super

    @_snake?.destroy()

  things: ->
    things = []

    if projectId = C1.Projects.Snake.readOnlyState 'activeProjectId'
      @_snake?.destroy()
      @_snake = new C1.Projects.Snake projectId

      things.push @_snake

    things
