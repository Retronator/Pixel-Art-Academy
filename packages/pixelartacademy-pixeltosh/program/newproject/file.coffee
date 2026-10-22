PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.NewProject.File extends PAA.Pixeltosh.OS.FileSystem.File
  @program: -> PAA.Pixeltosh.Programs.NewProject
  @iconUrl: -> @program().iconUrl()

  constructor: (projectClass, disk, folderPath = disk.path()) ->
    super
      id: "#{projectClass.id()}.NewProject"
      path: "#{folderPath}/#{_.titleCase projectClass.newAssetsProviderPlaceholder()}"
      type: PAA.Pixeltosh.Programs.NewProject.File
      disk: disk
      data: -> projectClass
