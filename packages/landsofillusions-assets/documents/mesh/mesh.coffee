AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 3D model asset.
class LOI.Assets.Mesh extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.Mesh'
  # name: text identifier for the mesh
  # cameraAngles: array of source images describing the mesh
  #   name: text identifier
  #   picturePlaneDistance: the distance in pixels the camera is away from the picture plane or null for ortographic
  #   pixelSize: the size of a camera pixel in world units
  #   position: location of the camera in world space
  #     x, y, z
  #   target: location of where the camera is pointing
  #     x, y, z
  #   up: up direction of the camera
  #     x, y, z
  #   sprite: source image visible from this camera angle
  #     _id
  @Meta
    name: @id()
    fields: =>
      cameraAngles: [
        sprite: @ReferenceField LOI.Assets.Sprite, [], false
      ]

  # Store the class name of the visual asset by which we can reach the class by querying LOI.Assets. We can't simply
  # use the name parameter, because in production the name field has a minimized value.
  @className: 'Mesh'
  
  constructor: ->
    super

    # Make rich camera angle objects.
    if @cameraAngles
      @cameraAngles[index] = new @constructor.CameraAngle data for data, index in @cameraAngles

  refresh: ->
    super

    # Also pull in all the sprites from the database.
    cameraAngle.sprite?.refresh() for cameraAngle in @cameraAngles

  # Subscriptions
  
  @forId: @subscription 'forId'
  @all: @subscription 'all'

  # Methods
  
  @insert: @method 'insert'
  @update: @method 'update'
  @clear: @method 'clear'
  @remove: @method 'remove'
  @duplicate: @method 'duplicate'
  
  @updateCameraAngle: @method 'updateCameraAngle'
