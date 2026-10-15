PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.NewProject.File extends PAA.Pixeltosh.OS.FileSystem.File
  @program: -> PAA.Pixeltosh.Programs.NewProject
  @iconUrl: -> @program().iconUrl()

  constructor: (projectClass, disk) ->
    super
      id: "#{projectClass.id()}.NewProject"
      path: "#{disk.path()}/#{_.titleCase projectClass.newAssetsProviderPlaceholder()}"
      type: PAA.Pixeltosh.Programs.NewProject.File
      disk: disk
      data: -> projectClass
