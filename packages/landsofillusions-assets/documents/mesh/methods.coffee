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
      solver: Match.Optional String
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
      ]
    ]
    materials: Match.Optional [
      name: Match.OptionalOrNull String
      type: Match.OptionalOrNull String
      ramp: Match.OptionalOrNull Number
      shade: Match.OptionalOrNull Number
      dither: Match.OptionalOrNull Number
      texture: Match.Optional
        spriteId: Match.Optional Match.DocumentId
        spriteName: Match.Optional String
        mappingMatrix: Match.Optional [Match.OptionalOrNull Number]
    ]

  RA.authorizeAdmin()

  # Update managed fields.
  LOI.Assets.Mesh.documents.update meshId, $set: data

vectorPattern =
  x: Number
  y: Number
  z: Number

sparseVectorPattern =
  x: Match.OptionalOrNull Number
  y: Match.OptionalOrNull Number
  z: Match.OptionalOrNull Number

mapPattern =
  compressedData: Match.Where EJSON.isBinary
