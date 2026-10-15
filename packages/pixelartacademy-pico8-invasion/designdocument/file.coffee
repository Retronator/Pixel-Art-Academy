PAA = PixelArtAcademy

DesignDocument = PAA.Pico8.Cartridges.Invasion.DesignDocument

class DesignDocument.File extends PAA.Pixeltosh.OS.FileSystem.ProjectFile
  constructor: (projectId, disk) ->
    super
      id: "#{DesignDocument.id()}.#{projectId}"
      type: PAA.Pixeltosh.Programs.Writer.TextDocument
      disk: disk
      data: =>
        documentComponentId: DesignDocument.id()
        projectId: projectId
        projectClassId: PAA.Pico8.Cartridges.Invasion.Project.id()

    @projectId = projectId

  path: ->
    # Read the name reactively so renaming a project also renames its document in Finder.
    project = PAA.Practice.Project.documents.findOne @projectId
    fileName = project?.name or "Invasion Design Document"
    "Invasion/#{fileName}"
