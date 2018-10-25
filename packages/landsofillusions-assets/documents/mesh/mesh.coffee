AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 3D model asset.
class LOI.Assets.Mesh extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.Mesh'
  # name: text identifier for the mesh
  # polygons: array of
  #   vertices: array of
  #     position: {x, y, z}
  #     normal: {x, y, z}
  #   indices: array of vertex indices that form triangles
  #   color: direct color of the polygon (or null if using indexed colors)
  #     r, g, b: (0.0-1.0)
  #   colorIndex: the index of the named color of the pixel (or null if using direct colors)
  #   relativeShade: which relative shade of the color should this polygon be
  # origin: [matrix] where the anchor point for the mesh is
  # palette: the color palette that this mesh uses
  #   _id
  #   name
  # colorMap: map from color indices to colors of the palette
  #   (colorIndex):
  #     name: what the color represents
  #     ramp: index of the ramp within the palette
  #     shade: the base shade to which polygon shades are relative to
  # bounds: mesh bounding box (or null if no polygons)
  #   min: {x, y, z}
  #   max: {x, y, z}
  @Meta
    name: @id()
    fields: =>
      palette: Document.ReferenceField LOI.Assets.Palette, ['name'], false

  # Store the class name of the visual asset by which we can reach the class by querying LOI.Assets. We can't simply
  # use the name parameter, because in production the name field has a minimized value.
  @className: 'Mesh'

  constructor: ->
    super arguments...
