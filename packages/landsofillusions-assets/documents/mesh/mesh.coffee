AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 3D model asset.
class LOI.Assets.Mesh extends LOI.Assets.VisualAsset
  @id: -> 'LandsOfIllusions.Assets.Mesh'
  # cameraAngles: array of scene viewpoints
  #   name: text identifier
  #   picturePlaneDistance: the distance in pixels the camera is away from the picture plane or null for ortographic
  #   picturePlaneOffset: offset of the center of the picture plane in pixels
  #     x, y
  #   pixelSize: the size of a camera pixel in world units
  #   position: location of the camera in world space
  #     x, y, z
  #   target: location of where the camera is pointing
  #     x, y, z
  #   up: up direction of the camera
  #     x, y, z
  # objects: array of scene objects
  #   name: name of the object
  #   visible: boolean if the object is rendered
  #   solver: name of the solver used to construct the mesh from the pictures
  #   layers: array of
  #     name: name of the layer
  #     visible: boolean if this layer should be drawn
  #     order: floating point order of the layer
  #     pictures: array of images that describe the object, indexed by cameraAngle index
  #       bounds: dimensions of the bitmap
  #         x, y: top-left corner relative to the camera origin (z-axis)
  #         width, height: size of the bitmap
  #       maps: object of texture maps that hold information for this picture
  #         {type}: what information is contained in this map, with possible values:
  #             mapFlags (1 byte per pixel: which of the maps are valid at each pixel)
  #             materialIndex (flag value 1, 1 byte per pixel: index)
  #             paletteColor (flag value 2, 2 bytes per pixel: ramp, shade)
  #             directColor (flag value 4, 3 bytes per pixel: r, g, b)
  #             alpha (flag value 8, 1 byte per pixel: a)
  #             normal (flag value 16, 3 bytes per pixel: x, y, z as signed bytes (-1 to 1 float mapped to -127 to 127))
  #           data: array buffer holding the pixels, not sent to the server
  #           compressedData: binary object with compressed version of data, sent to the server
  # materials: array of shaders used to draw objects
  #   name: what the materials represents
  #   type: ID of the shader
  #   ramp: index of the ramp within the palette
  #   shade: index of the shade in the ramp
  #   dither: amount of dither used from 0 to 1
  @Meta
    name: @id()
    fields: =>
      cameraAngles: [
        sprite: Document.ReferenceField LOI.Assets.Sprite, [], false
      ]

  # Store the class name of the visual asset by which we can reach the class by querying LOI.Assets. We can't simply
  # use the name parameter, because in production the name field has a minimized value.
  @className: 'Mesh'
  
  initialize: ->
    # Track whether we need to save the mesh.
    @dirty = new ReactiveField false
    @_updatedDependency = new Tracker.Dependency

    # Initialize array fields
    @cameraAngles = new @constructor.ArrayField @, 'cameraAngles', @cameraAngles, @constructor.CameraAngle
    @objects = new @constructor.ArrayField @, 'objects', @objects, @constructor.Object
    @materials = new @constructor.ArrayField @, 'materials', @materials

    # After mesh is initialized, mark to be in saved state.
    @dirty false
    
  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @dirty true
    @_updatedDependency.changed()

  save: ->
    saveData = {}
      
    # Save array fields.
    @cameraAngles.save saveData
    @objects.save saveData
    @materials.save saveData

    # Send the mesh to server.
    LOI.Assets.Mesh.save @_id, saveData

    # Mark the state clean.
    @dirty false

  # Methods
  
  @save: @method 'save'

if Meteor.isServer
  # Export meshes without authors.
  LOI.GameContent.addToExport ->
    LOI.Assets.Mesh.documents.fetch authors: $exists: false
