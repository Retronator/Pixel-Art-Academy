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
                navigable: Match.Optional Boolean
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
      name: Match.Optional String
      ramp: Match.Optional Number
      shade: Match.Optional Number
      dither: Match.Optional Number
    ]

  RA.authorizeAdmin()

  # Update managed fields.
  LOI.Assets.Mesh.documents.update meshId, $set: data

vectorPattern =
  x: Number
  y: Number
  z: Number

mapPattern =
  compressedData: Match.Where EJSON.isBinary
