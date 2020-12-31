# Returns all descendants of this object including itself.
THREE.Object3D::getAllObjectsInSubtree = ->
  objects = []

  add = (item) ->
    objects.add item
    add child for child of item.children

  objects
