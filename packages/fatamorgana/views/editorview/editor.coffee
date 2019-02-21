AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana

class FM.EditorView.Editor extends FM.View
  onCreated: ->
    super arguments...

    @editorView = @ancestorComponentOfType FM.EditorView
    @editorFileData = new ComputedField => @editorView.activeFileData()

    if dataFields = @constructor.editorFileDataFieldsWithDefaults?()
      for dataField, defaultValue of dataFields
        do (dataField, defaultValue) =>
          @[dataField] = new ComputedField =>
            @editorFileData()?.get(dataField) ? defaultValue
