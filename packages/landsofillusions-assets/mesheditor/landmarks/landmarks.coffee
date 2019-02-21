AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Landmarks extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Landmarks'
  @register @id()

  onCreated: ->
    super arguments...

    @landmarksHelper = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.Landmarks

    @landmarks = new ComputedField =>
      # Only show the subset of landmarks for the current object/layer/picture.
      return unless meshCanvas = @interface.getEditorForActiveFile()

      _.filter @landmarksHelper()?.landmarks(), (landmark) =>
        landmark.object is meshCanvas.activeObjectIndex() and
          landmark.layer is meshCanvas.activeLayerIndex() and
          landmark.cameraAngle is meshCanvas.cameraAngleIndex()

  showAddButton: ->
    # We can only add landmarks when we're on an active layer.
    return unless meshCanvas = @interface.getEditorForActiveFile()

    meshCanvas.activeObject() and meshCanvas.activeLayer()

  # Events

  events: ->
    super(arguments...).concat
      'change .number-input': @onChangeNumber
      'change .name-input, change .coordinate-input': @onChangeLandmark
      'click .add-landmark-button': @onClickAddLandmarkButton

  onChangeNumber: (event) ->
    landmark = @currentData()

    number = parseInt $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val landmark.number

    asset = @landmarksHelper().asset()

    if _.isNaN number
      LOI.Assets.VisualAsset.removeLandmark asset.constructor.className, asset._id, landmark.index

    else
      newIndex = number - 1
      LOI.Assets.VisualAsset.reorderLandmark asset.constructor.className, asset._id, landmark.index, newIndex

  onChangeLandmark: (event) ->
    $landmark = $(event.target).closest('.landmark')

    index = @currentData().index

    landmark =
      # We null the name if it's an empty string
      name: $landmark.find('.name-input').val() or null
      
    for property in ['x', 'y']
      value = @_parseFloatOrNull $landmark.find(".coordinate-#{property} .coordinate-input").val()
      landmark[property] = value if value?

    asset = @landmarksHelper().asset()
    LOI.Assets.VisualAsset.updateLandmark asset.constructor.className, asset._id, index, landmark

  onClickAddLandmarkButton: (event) ->
    asset = @landmarksHelper().asset()
    index = asset.landmarks?.length or 0
    meshCanvas = @interface.getEditorForActiveFile()

    LOI.Assets.VisualAsset.updateLandmark asset.constructor.className, asset._id, index,
      object: meshCanvas.activeObjectIndex()
      layer: meshCanvas.activeLayerIndex()
      cameraAngle: meshCanvas.cameraAngleIndex()

  _parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float
