AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.AddReferenceByUrl extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, url, properties) ->
    super arguments...
  
    # Create the image document if we haven't yet.
    profileId = asset.profileId
    
    if existingImage = LOI.Assets.Image.documents.findOne {profileId, url}
      imageId = existingImage._id
      
    else
      imageId = LOI.Assets.Image.documents.insert
        profileId: profileId
        lastEditTime: new Date()
        url: url
    
    reference = _.extend
      image:
        _id: imageId
        # Also inject the URL so we don't have to wait for reference to kick in.
        url: url
        order: highestOrder + 1
    ,
      properties
    
    # Place the new reference on top of existing references.
    if asset.references
      highestOrder = _.max _.map asset.references, (reference) => reference.order or 0
      reference.order = highestOrder + 1
    
    # Forward operation adds the reference.
    forwardOperation = new LOI.Assets.VisualAsset.Operations.AddReference {reference}

    # Backward operation removes the reference.
    backwardOperation = new LOI.Assets.VisualAsset.Operations.RemoveReference
      index: asset.references?.length or 0

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
