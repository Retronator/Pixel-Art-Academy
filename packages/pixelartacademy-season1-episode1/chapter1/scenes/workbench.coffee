LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_snake?.destroy()

  things: ->
    things = []

    if projectId = PAA.Pico8.Cartridges.Snake.Project.readOnlyState 'activeProjectId'
      @_snake?.destroy()
      @_snake = new PAA.Pico8.Cartridges.Snake.Project projectId

      things.push @_snake

    things
