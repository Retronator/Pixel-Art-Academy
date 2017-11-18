AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 2D image asset.
class LOI.Assets.VisualAsset extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.VisualAsset'
  # name: text identifier for the sprite
  # palette: the color palette that this sprite uses (or null if only direct colors are used)
  #   _id
  #   name
  # materials: map of named colors
  #   (materialIndex):
  #     name: what the color represents
  #     ramp: index of the ramp within the palette
  #     shade: index of the shade in the ramp
  # landmarks: array of named locations
  #   name: name of the landmark
  #   x, y, z: floating point location of the landmark
  # history: list of operations that produce this image
  #   forward: update delta that creates the result of the operation
  #   backward: update delta that undoes the operation from the resulting state
  @Meta
    abstract: true
    fields: =>
      palette: @ReferenceField LOI.Assets.Palette, ['name'], false

  @updatePalette: @method 'updatePalette'
  @updateMaterial: @method 'updateMaterial'
  @updateLandmark: @method 'updateLandmark'

  # Child documents should implement these.
  @forId: null
  @all: null

  @insert: null
  @update: null
  @clear: null
  @remove: null
  @duplicate: null

  constructor: ->
    super

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1

  getLandmarkForName: (name) ->
    _.find @landmarks, (landmark) -> landmark.name is name
