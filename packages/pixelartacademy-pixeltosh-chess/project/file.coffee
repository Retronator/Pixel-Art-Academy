PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project.File extends PAA.Pixeltosh.OS.FileSystem.ProjectFile
  constructor: (projectClass, projectId, disk) ->
    super
      id: "#{projectClass.id()}.#{projectId}"
      type: projectClass
      disk: disk
      data: ->
        projectId: projectId
        projectClassId: projectClass.id()

    @projectClass = projectClass
    @projectId = projectId

  path: ->
    project = PAA.Practice.Project.documents.findOne @projectId
    name = project?.name or _.titleCase Chess.Project.getWorkbenchInstance().defaultAssetsProviderName()
    "Chess Academy/Chess Sets/#{name}"
