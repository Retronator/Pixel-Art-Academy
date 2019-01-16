AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.ShowAction extends LOI.Assets.Editor.Actions.AssetAction
  @fileDataProperty: -> throw new AE.NotImplementedException "Show action must specify the file data field."
    
  active: ->
    # We assume the editor has a field defined with the property name.
    property = @constructor.fileDataProperty()
    @editor()[property]()

  execute: ->
    property = @constructor.fileDataProperty()
    fileData = @editorView().activeFileData()
    fileData.set property, not @active()
