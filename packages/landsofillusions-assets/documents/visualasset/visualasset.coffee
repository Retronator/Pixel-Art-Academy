AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.VisualAsset'
  # name: text identifier for the sprite
  # palette: the color palette that this sprite uses (or null if only direct colors are used)
  #   _id
  #   name
  # customPalette: optional embedded palette object with the same structure as a palette document
  # materials: map of named colors
  #   (materialIndex):
  #     name: what the color represents
  #     ramp: index of the ramp within the palette
  #     shade: index of the shade in the ramp
  # landmarks: array of named locations
  #   name: name of the landmark
  #   x, y, z: floating point location of the landmark
  # history: array of operations that produce this image
  #   forward: update delta that creates the result of the operation
  #   backward: update delta that undoes the operation from the resulting state
  # authors: array of characters that are allowed to edit this asset or null if this is a system asset
  #   _id
  #   avatar
  #     fullName
  # references: array of images used as references
  #   image: image document
  #     _id
  #     url
  #   displayed: boolean if the reference is currently displayed
  #   position: data for where to display the reference
  #     x, y: floating point position values
  #   scale: data for how big to display the reference
  #   order: integer value for sorting references
  @Meta
    abstract: true
    fields: =>
      palette: @ReferenceField LOI.Assets.Palette, ['name'], false
      authors: [@ReferenceField LOI.Character, ['avatar.fullName']]
      references: [
        image: @ReferenceField LOI.Assets.Image, ['url']
      ]

  @updatePalette: @method 'updatePalette'
  @updateMaterial: @method 'updateMaterial'
  @updateLandmark: @method 'updateLandmark'

  @addReferenceByUrl: @method 'addReferenceByUrl'
  @updateReferenceScale: @method 'updateReferenceScale'
  @updateReferencePosition: @method 'updateReferencePosition'
  @updateReferenceDisplayed: @method 'updateReferenceDisplayed'
  @reorderReferenceToTop: @method 'reorderReferenceToTop'

  # Child documents should implement these.
  @forId: null
  @all: null

  @insert: null
  @update: null
  @clear: null
  @remove: null
  @duplicate: null
  
  @_authorizeAssetAction: (asset) ->
    # See if user controls one of the author characters.
    authors = asset.authors or []
  
    for author in authors
      try
        LOI.Authorize.characterAction author._id
  
        # If error was not thrown, this author is controlled by the user and action is approved.
        return
  
      catch
        # This author is not controlled by the user.
        continue
  
    # No author was authorized. Only allow editing if the user is an admin.
    RA.authorizeAdmin()

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
