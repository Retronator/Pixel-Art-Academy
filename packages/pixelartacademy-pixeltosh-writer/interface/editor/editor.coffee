AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Writer = PAA.Pixeltosh.Programs.Writer

class Writer.Interface.Editor extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Writer.Interface.Editor'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @interfaceWindow = @ancestorComponentOfType PAA.Pixeltosh.OS.Interface.Window

    # Rename the window title to the document name.
    @autorun (computation) =>
      return unless documentFileId = @data().get 'documentFileId'
      return unless documentFile = @os.fileSystem.getFileForId documentFileId
      documentName = documentFile.name()

      Tracker.nonreactive => @interfaceWindow.data().set 'title.text', documentName

  documentData: -> @data().get 'documentData'
