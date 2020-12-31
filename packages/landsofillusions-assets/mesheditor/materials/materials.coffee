AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Materials extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Materials'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    # Deselect index if it's outside asset's materials.
    @autorun (computation) =>
      return unless index = @paintHelper.materialIndex()
      return if @mesh()?.materials.get index
      
      Tracker.nonreactive => @paintHelper.setMaterialIndex null

  setIndex: (index) ->
    # Make sure index is a number and not a string. But it could be null too for deselecting.
    index = parseInt index if index?

    # Set current material index.
    @paintHelper.setMaterialIndex index

  selectIndexWithRamp: (ramp) ->
    @paintHelper.setMaterialIndex @getIndexWithRamp ramp

  getIndexWithRamp: (ramp) ->
    mesh = @mesh()
    return unless mesh

    currentIndex = @paintHelper.materialIndex()

    # Skip if current index is already with desired ramp
    return currentIndex if mesh.materials[currentIndex]?.ramp is ramp

    # Find first index with this ramp.
    for index of mesh.materials
      if mesh.materials[index].ramp is ramp
        return parseInt index

    # No indexed color matches this ramp.
    null

  addNewIndex: ->
    index = @mesh().materials.insert @paintHelper.paletteColor()

    # Switch to new material
    @setIndex index

  # Helpers

  materials: ->
    @mesh()?.materials.getAll()

  colorPreviewStyle: ->
    material = @currentData()
    return unless palette = LOI.Assets.Palette.documents.findOne @mesh()?.palette?._id

    ramp = material.ramp or 0
    return unless shades = palette.ramps[ramp]?.shades

    maxShade = shades.length - 1
    shade = THREE.Math.clamp material.shade or 0, 0, maxShade
    color = THREE.Color.fromObject shades[shade]

    backgroundColor: "##{color.getHexString()}"

  activeColorClass: ->
    material = @currentData()
    'active' if material.index is @paintHelper.materialIndex()

  events: ->
    super(arguments...).concat
      'click .preview-color': @onClickPreviewColor
      'dblclick .preview-color': @onDoubleClickPreviewColor
      'change .name-input': @onChangeName
      'click .add-material-button': @onClickAddMaterialButton

  onClickPreviewColor: (event) ->
    material = @currentData()
    @setIndex material.index

  onDoubleClickPreviewColor: (event) ->
    material = @currentData()

    @interface.displayDialog
      contentComponentId: LOI.Assets.MeshEditor.MaterialDialog.id()
      contentComponentData:
        materialIndex: material.index

  onChangeName: (event) ->
    material = @currentData()

    material.update
      # We null the name if it's an empty string
      name: $(event.target).val() or null

  onClickAddMaterialButton: (event) ->
    @addNewIndex()
