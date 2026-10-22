FM = FataMorgana
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.OpenDialog extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.OpenDialog'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    canDismiss: false
    left: 0
    right: 0
    top: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @pinball = @os.getProgram Pinball
    
    @selectedFileId = new ReactiveField null
  
    @machines = new ComputedField =>
      disk = @os.fileSystem.getFileForId "#{Pinball.id()}.Disk"
      diskPathPrefix = "#{disk.path()}/"
      
      machines = for file in @os.fileSystem.files() when file.type() is Pinball.Project
        path = file.path()
        continue unless _.startsWith path, diskPathPrefix
  
        file: file
        name: path.substring(diskPathPrefix.length).split('/').join ' / '
  
      # Display user machines above demo machines.
      _.sortBy machines, [
        (machine) => not (machine.file instanceof Pinball.Project.File)
        (machine) =>
          projectId = machine.file.data().projectId
          project = PAA.Practice.Project.documents.findOne projectId
          # Sort by creation time for user machines and name for demo machines.
          project?.startTime or machine.name
      ]

  scrollbars: ->
    vertical:
      enabled: true

  selectedFile: ->
    return unless selectedFileId = @selectedFileId()
    
    selectedMachine = _.find @machines(), (machine) => machine.file.id() is selectedFileId
    selectedMachine.file

  selectedClass: ->
    machine = @currentData()
    'selected' if machine.file.id() is @selectedFileId()

  openDisabledAttribute: ->
    disabled: true unless @selectedFile()

  onBackButton: ->
    @closeDialog()

    # Inform that we've handled the back button.
    true

  events: ->
    super(arguments...).concat
      'click .machine': @onClickMachine
      'dblclick .machine': @onDoubleClickMachine
      'click .open-button': @onClickOpen
      'click .cancel-button': @onClickCancel

  onClickMachine: ->
    @selectedFileId @currentData().file.id()

  onDoubleClickMachine: ->
    @onClickMachine()
    @onClickOpen()

  onClickOpen: ->
    return unless file = @selectedFile()
    @closeDialog()

    # Restart with the new file.
    @pinball.restart file

  onClickCancel: ->
    @closeDialog()
