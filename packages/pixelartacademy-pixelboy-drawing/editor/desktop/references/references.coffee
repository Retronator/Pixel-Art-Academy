AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References extends FM.View
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.References'
  @register @id()

  @template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @desktop = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Desktop

    @displayComponent = new PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References.DisplayComponent
      assetData: => @interface.getLoaderForActiveFile()?.asset()
      editorActive: => @desktop.active()
      assetOptions: => @desktop.displayedAsset()?.editorOptions?()?.references
