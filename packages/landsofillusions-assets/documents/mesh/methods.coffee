AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Mesh.load.method (meshId) ->
  check meshId, Match.DocumentId

  LOI.Assets.Mesh.documents.findOne meshId

LOI.Assets.Mesh.save.method (meshId, data) ->
  check meshId, Match.DocumentId
  check data,
    cameraAngles: Match.Optional [ Match.OptionalOrNull
      name: Match.Optional String
      picturePlaneDistance: Match.OptionalOrNull Number
      picturePlaneOffset: Match.Optional
        x: Number
        y: Number
      pixelSize: Match.OptionalOrNull Number
      position: Match.Optional vectorPattern
      target: Match.Optional vectorPattern
      up: Match.Optional vectorPattern
      customMatrix: Match.Optional [Match.OptionalOrNull Number]
    ]
    objects: Match.Optional [ Match.OptionalOrNull
      name: Match.Optional String
      visible: Match.Optional Boolean
      solver: Match.Optional
        type: Match.Optional String
        polyhedron: Match.Optional
          cleanEdgePixels: Match.Optional Boolean
      lastClusterId: Match.Optional Match.Integer
      layers: Match.Optional [ Match.OptionalOrNull
        name: Match.Optional String
        visible: Match.Optional Boolean
        order: Match.Optional Number
        pictures: Match.OptionalOrNull [ Match.OptionalOrNull
          cameraAngle: Match.Optional Match.Integer
          bounds: Match.Optional
            x: Match.Integer
            y: Match.Integer
            width: Match.Integer
            height: Match.Integer
          maps: Match.Optional
            flags: Match.Optional mapPattern
            clusterId: Match.Optional mapPattern
            materialIndex: Match.Optional mapPattern
            paletteColor: Match.Optional mapPattern
            directColor: Match.Optional mapPattern
            alpha: Match.Optional mapPattern
            normal: Match.Optional mapPattern
          clusters: Match.Optional Match.Where (clusters) ->
            for id, cluster of clusters
              check parseInt(id), Match.Integer
              check cluster,
                sourceCoordinates:
                  x: Match.Integer
                  y: Match.Integer
        ]
        clusters: Match.Optional Match.Where (clusters) ->
          for id, cluster of clusters
            check parseInt(id), Match.Integer
            check cluster,
              properties: Match.Optional
                name: Match.Optional String
                navigable: Match.Optional Boolean
                coplanarPoint: Match.Optional sparseVectorPattern
                attachment: Match.Optional String
                extrusion: Match.Optional Number
              plane: Match.Optional
                point: vectorPattern
                normal: vectorPattern
              material: Match.Optional
                paletteColor: Match.Optional
                  ramp: Match.Integer
                  shade: Match.Integer
                directColor: Match.Optional
                  r: Number
                  g: Number
                  b: Number
                materialIndex: Match.Optional Match.Integer
                alpha: Match.Optional Number
                normal: Match.Optional vectorPattern
              geometry: Match.Optional
                compressedVertices: Match.Where EJSON.isBinary
                compressedNormals: Match.Where EJSON.isBinary
                compressedIndices: Match.Where EJSON.isBinary
                compressedPixelCoordinates: Match.Where EJSON.isBinary
                compressedLayerPixelCoordinates: Match.Where EJSON.isBinary
              boundsInPicture:
                x: Number
                y: Number
                width: Number
                height: Number
      ]
    ]
    materials: Match.Optional [
      name: Match.OptionalOrNull String
      type: Match.OptionalOrNull String
      ramp: Match.OptionalOrNull Number
      shade: Match.OptionalOrNull Number
      dither: Match.OptionalOrNull Number
      reflection: Match.Optional
        intensity: Match.OptionalOrNull Number
        shininess: Match.OptionalOrNull Number
        smoothFactor: Match.OptionalOrNull Number
      translucency: Match.Optional
        amount: Match.OptionalOrNull Number
        dither: Match.OptionalOrNull Number
        tint: Match.OptionalOrNull Boolean
        blending: Match.Optional
          preset: Match.OptionalOrNull String
          equation: Match.OptionalOrNull String
          sourceFactor: Match.OptionalOrNull String
          destinationFactor: Match.OptionalOrNull String
        shadow: Match.Optional
          dither: Match.OptionalOrNull Number
          tint: Match.OptionalOrNull Boolean
      materialClass: Match.OptionalOrNull String
      refractiveIndex: Match.OptionalOrNull rgbPattern
      extinctionCoefficient: Match.OptionalOrNull rgbPattern
      temperature: Match.OptionalOrNull Number
      emission: Match.OptionalOrNull rgbPattern
      texture: Match.Optional
        spriteId: Match.OptionalOrNull Match.DocumentId
        spriteName: Match.OptionalOrNull String
        mappingMatrix: Match.Optional [Match.OptionalOrNull Number]
        mappingOffset: Match.Optional
          x: Number
          y: Number
        anisotropicFiltering: Match.OptionalOrNull Boolean
        minificationFilter: Match.OptionalOrNull String
        magnificationFilter: Match.OptionalOrNull String
        mipmapFilter: Match.OptionalOrNull String
        mipmapBias: Match.OptionalOrNull Number
    ]

  RA.authorizeAdmin()

  data.lastEditTime = new Date

  # Update managed fields.
  LOI.Assets.Mesh.documents.update meshId, $set: data

vectorPattern =
  x: Number
  y: Number
  z: Number

rgbPattern =
  r: Number
  g: Number
  b: Number

sparseVectorPattern =
  x: Match.OptionalOrNull Number
  y: Match.OptionalOrNull Number
  z: Match.OptionalOrNull Number

mapPattern =
  compressedData: Match.Where EJSON.isBinary
