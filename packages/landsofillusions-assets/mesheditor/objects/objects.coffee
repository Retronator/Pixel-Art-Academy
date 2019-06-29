AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Objects extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Objects'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @meshCanvas = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @selection = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.Selection

    @objectIndex = new ComputedField =>
      @selection()?.objectIndex()

    @object = new ComputedField =>
      @mesh()?.objects.get @objectIndex()

  setObjectIndex: (index) ->
    @selection().setObjectIndex index

  objects: ->
    @mesh()?.objects.getAll()

  active: ->
    object = @currentData()
    object.index is @objectIndex()

  activeClass: ->
    'active' if @active()

  visibleCheckedAttribute: ->
    object = @currentData()
    checked: true if object.visible() ? true

  placeholderName: ->
    object = @currentData()
    "Object #{object.index}"

  objectThumbnail: ->
    object = @currentData()

    return unless meshCanvas = @meshCanvas()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()

    return unless loader = @interface.getLoaderForActiveFile()

    pictureThumbnails = for layer in object.layers.getAll()
      picture = layer.getPictureForCameraAngleIndex cameraAngleIndex
      loader.getPictureThumbnail picture

    new LOI.Assets.MeshEditor.Thumbnail.Pictures pictureThumbnails

  nameDisabledAttribute: ->
    # Disable name editing until the object is active.
    disabled: true unless @active()
    
  placeholderClass: ->
    object = @currentData()
    'placeholder' unless object.name()

  showRemoveButton: ->
    # We can remove an object if it exists.
    @object()

  events: ->
    super(arguments...).concat
      'click .object': @onClickObject
      'change .name-input, change .visible-checkbox': @onChangeObject
      'click .add-button': @onClickAddButton
      'click .remove-button': @onClickRemoveButton

  onClickObject: (event) ->
    object = @currentData()
    @setObjectIndex object.index

  onChangeObject: (event) ->
    object = @currentData()
    $layer = $(event.target).closest('.object')

    object.name $layer.find('.name-input').val()
    object.visible $layer.find('.visible-checkbox').is(':checked')

  onClickAddButton: (event) ->
    mesh = @mesh()
    index = mesh.objects.insert()

    @setObjectIndex index

  onClickRemoveButton: (event) ->
    @mesh().objects.remove @objectIndex()
