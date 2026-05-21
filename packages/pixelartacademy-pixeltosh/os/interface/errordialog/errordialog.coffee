FM = FataMorgana
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.ErrorDialog extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.ErrorDialog'
  @register @id()

  @createInterfaceData: (options) ->
    contentComponentId: @id()
    contentComponentData: options
    canDismiss: false
    left: 0
    right: 0
    top: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS

  events: ->
    super(arguments...).concat
      'click .shut-down-button': @onClickShutDownButton

  onClickShutDownButton: (event) ->
    options = @data()
    
    @os.unloadProgram options.shutDownProgram
    @closeDialog()
