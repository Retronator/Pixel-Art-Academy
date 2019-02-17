AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.ShowAction extends LOI.Assets.Editor.Actions.AssetAction
  @fileDataProperty: -> throw new AE.NotImplementedException "Show action must specify the file data field."
    
  active: ->
    return unless editor = @editor()

    property = @constructor.fileDataProperty()

    # We see if the editor has a field defined with the property name.
    # We use this first in case the editor overrides the default value.
    if field = editor[property]
      field()

    else
      # We read the value directly from data.
      fileData = @editorView().activeFileData()
      fileData.get property

  execute: ->
    return unless editorView = @editorView()

    property = @constructor.fileDataProperty()
    fileData = editorView.activeFileData()
    fileData.set property, not @active()
