AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.VisualAsset extends LOI.Assets.Asset
  @id: -> 'LandsOfIllusions.Assets.VisualAsset'
  # palette: the color palette that this sprite uses (or null if only direct colors are used)
  #   _id
  #   name
  # customPalette: optional embedded palette object with the same structure as a palette document
  # materials: map of named colors
  #   (materialIndex):
  #     name: what the color represents
  #     ramp: index of the ramp within the palette
  #     shade: index of the shade in the ramp
  #     dither: amount of dither used from 0 to 1
  #     reflection: information about specular reflections
  #       intensity: how strong the reflections is, from 0 upwards
  #       shininess: how sharp the reflection is, from 0 upwards.
  #       smoothFactor: integer size of the blur kernel to smooth the normals
  # landmarks: array of named locations
  #   name: name of the landmark
  #   x, y, z: floating point location of the landmark
  # references: array of images used as references
  #   image: image document
  #     _id
  #     url
  #   displayed: boolean if the reference is currently displayed
  #   position: data for where to display the reference
  #     x, y: floating point position values
  #   scale: data for how big to display the reference
  #   order: integer value for sorting references
  #   displayMode: where to display the reference (inside the image, over the interface …)
  # environments: array of HDR images used to light the scene
  #   image: image document
  #     _id
  #     url
  #   active: boolean if the environment is the one to be used to light the asset
  # properties: extra properties the player can define for the asset
  #   pixelArtScaling: boolean whether the asset is pixel art and should be scaled up with nearest neighbor
  #   normals: boolean whether the asset has normal painting turned on
  #   paletteIds: array of palettes that should be available to the player (but not restrict the colors)
  #   pixelArtGrading: object or null whether to show the pixel art grading rubric
  #     editable: boolean whether grading criteria can be toggled on and off
  #     score: float between 0 and 1 for the final average grade
  #     consistentLineWidth, evenDiagonals, smoothCurves: objects with different criteria evaluations
  #       editable: boolean overriding whether grading criteria can be toggled on and off
  #       score: float between 0 and 1 with this criterion evaluation
  #       ...: any extra information provided relating to this criterion
  @Meta
    abstract: true
    fields: =>
      palette: Document.ReferenceField LOI.Assets.Palette, ['name'], false
      references: [
        image: Document.ReferenceField LOI.Assets.Image, ['url']
      ]

  @ReferenceDisplayModes:
    EmbeddedUnder: 'EmbeddedUnder'
    EmbeddedOver: 'EmbeddedOver'
    FloatingInside: 'FloatingInside'
    FloatingOutside: 'FloatingOutside'

  # Methods

  @updatePalette: @method 'updatePalette'
  @updateMaterial: @method 'updateMaterial'

  @updateLandmark: @method 'updateLandmark'
  @reorderLandmark: @method 'reorderLandmark'
  @removeLandmark: @method 'removeLandmark'

  @addReferenceByUrl: @method 'addReferenceByUrl'
  @updateReferenceScale: @method 'updateReferenceScale'
  @updateReferencePosition: @method 'updateReferencePosition'
  @updateReferenceDisplayed: @method 'updateReferenceDisplayed'
  @updateReferenceDisplayMode: @method 'updateReferenceDisplayMode'
  @reorderReferenceToTop: @method 'reorderReferenceToTop'

  @addEnvironmentByUrl: @method 'addEnvironmentByUrl'
  @activateEnvironment: @method 'activateEnvironment'

  # Subscriptions

  @allSystem: @subscription 'allSystem'
  
  @toPlainObject: (visualAsset) ->
    plainObject = LOI.Assets.Asset.toPlainObject visualAsset
  
    _.assign plainObject, _.pick visualAsset, ['customPalette', 'materials', 'landmarks', 'authors', 'references']
    plainObject.palette = _.pick visualAsset.palette, ['_id', 'name'] if visualAsset.palette
  
    if plainObject.references
      plainObject.references = _.cloneDeep plainObject.references
      reference.image = _.pick reference.image, ['_id', 'url'] for reference in plainObject.references
  
    plainObject

  constructor: ->
    super arguments...

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1
      
    # For backwards compatibility, if no properties are present, a pixel art asset is assumed.
    @properties ?=
      pixelArtScaling: true
  
  hasRestrictedPalette: ->
    @palette or @customPalette
    
  getAllPaletteIds: ->
    paletteIds = []
  
    if @palette
      paletteIds.push @palette._id
  
    if @properties?.paletteIds
      paletteIds.push @properties?.paletteIds...
  
    paletteIds
  
  getRestrictedPalette: ->
    return unless @hasRestrictedPalette()
    
    @customPalette or LOI.Assets.Palette.documents.findOne @palette._id
    
  getAllPalettes: ->
    palettes = []
    
    if @hasRestrictedPalette()
      palettes.push @getRestrictedPalette()
    
    if @properties?.paletteIds
      palettes.push LOI.Assets.Palette.documents.fetch(_id: $in: @properties.paletteIds)...
    
    palettes
    
  allPalettesAvailable: ->
    return false if @hasRestrictedPalette() and not @getRestrictedPalette()
    
    if @properties?.paletteIds
      for paletteId in @properties.paletteIds
        return false unless LOI.Assets.Palette.documents.findOne paletteId
        
    true
  
  getLandmarkForName: (name, flipped) ->
    if flipped
      originalName = name
      name = name.replace('Left', '_').replace('Right', 'Left').replace('_', 'Right')

    landmark = _.find @landmarks, (landmark) -> landmark.name is name

    if landmark and flipped
      landmark = _.extend {}, landmark,
        x: -landmark.x
        name: originalName

    else
      landmark
      
  clear: ->
    @constructor.clear @_id

  toPlainObject: ->
    plainObject = super arguments...

    _.assign plainObject, _.pick @, ['customPalette', 'materials', 'landmarks', 'authors', 'references']
    plainObject.palette = _.pick @palette, ['_id', 'name'] if @palette
  
    if plainObject.references
      plainObject.references = _.cloneDeep plainObject.references
      reference.image = _.pick reference.image, ['_id', 'url'] for reference in plainObject.references
    
    plainObject
