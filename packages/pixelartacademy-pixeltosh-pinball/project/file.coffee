PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project.File extends PAA.Pixeltosh.OS.FileSystem.ProjectFile
  constructor: (projectId, disk) ->
    super
      id: "#{Pinball.Project.id()}.#{projectId}"
      type: Pinball.Project
      disk: disk
      data: ->
        projectId: projectId
        projectClassId: Pinball.Project.id()

    @projectId = projectId

  path: ->
    project = PAA.Practice.Project.documents.findOne @projectId
    name = project?.name or "My Pinball Machine"
    "Pinball Creation Kit/#{name}"
