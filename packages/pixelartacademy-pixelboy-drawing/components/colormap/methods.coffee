LOI = LandsOfIllusions

Meteor.methods
  colorMapSetColor: (assetId, assetClassName, index, name, ramp, shade) ->
    check assetId, Match.DocumentId
    check assetClassName, String
    check index, Match.Integer
    check name, Match.OptionalOrNull String
    check ramp, Match.OptionalOrNull Match.Integer
    check shade, Match.OptionalOrNull Match.Integer

    # Make sure the document collection exists.
    Asset = LOI.Assets[assetClassName]
    throw new Meteor.Error 'invalid-argument', "Asset class name doesn't exist." unless Asset

    # Get existing color or create new entry.
    color = Asset.documents.findOne(assetId).colorMap[index] or
    name: ''
    ramp: 0
    shade: 0

    # Update the fields that are set.
    color.name = name if name?
    color.ramp = ramp if ramp?
    color.shade = shade if shade?

    Asset.documents.update assetId,
      $set:
        "colorMap.#{index}": color
