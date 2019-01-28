FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.Selection extends FM.Helper
  # objectIndex: the index of the selected object
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.Selection'
  @initialize()

  constructor: ->
    super arguments...

    @activeFileData = new ComputedField =>
      @interface.getComponentDataForActiveFile @

  objectIndex: -> @activeFileData().get('objectIndex') or 0

  setObjectIndex: (index) ->
    @activeFileData().set 'objectIndex', index
