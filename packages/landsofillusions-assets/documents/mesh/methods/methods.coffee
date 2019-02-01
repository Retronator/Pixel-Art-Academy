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
        pictures: Match.OptionalOrNull [ Match.OptionalOrNull
          cameraAngle: Match.Optional Number
          bounds: Match.Optional
            x: Number
            y: Number
            width: Number
            height: Number
          maps: Match.Optional
            flags: Match.Optional mapPattern
            materialIndex: Match.Optional mapPattern
            paletteColor: Match.Optional mapPattern
            directColor: Match.Optional mapPattern
            alpha: Match.Optional mapPattern
            normal: Match.Optional mapPattern
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

mapPattern =
  compressedData: Match.Where EJSON.isBinary
