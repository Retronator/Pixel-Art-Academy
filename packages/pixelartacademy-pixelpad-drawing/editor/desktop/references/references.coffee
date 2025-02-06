AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References extends FM.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.References'
  @register @id()

  onCreated: ->
    super arguments...

    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop

    @displayComponent = new PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent
      assetData: => @interface.getLoaderForActiveFile()?.asset()
      editorActive: => @desktop.active()
      editorSize: => @desktop.drawing.os.pixelPad.size()
      assetOptions: => @desktop.displayedAsset()?.editorOptions?()?.references
