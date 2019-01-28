AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Mesh.save.method (meshId, data) ->
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
      layers: Match.Optional [ Match.OptionalOrNull
        name: Match.Optional String
        visible: Match.Optional Boolean
        order: Match.Optional Number
        pictures: Match.Optional [
          cameraAngle: Match.Optional Number
          bounds: Match.Optional
            left: Number
            right: Number
            top: Number
            bottom: Number
          maps: Match.Optional [
            mapType: Match.Optional String
            compressedData: Match.Where EJSON.isBinary
          ]
        ]
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
