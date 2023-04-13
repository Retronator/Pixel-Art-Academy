AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.AddReferenceByUrl extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, url, properties) ->
    super arguments...
  
    # Create the image document if we haven't yet.
    profileId = asset.profileId
    
    if existingImage = LOI.Assets.Image.documents.find {profileId, url}
      imageId = existingImage._id
      
    else
      imageId = LOI.Assets.Image.insert
        profileId: profileId
        lastEditTime: new Date()
        url: url
    
    reference = _.extend
      image:
        _id: imageId
        # Also inject the URL so we don't have to wait for reference to kick in.
        url: url
    ,
      properties
    
    # Forward operation adds the reference.
    forwardOperation = new LOI.Assets.VisualAsset.Operations.AddReference {reference}

    # Backward operation removes the reference.
    backwardOperation = new LOI.Assets.VisualAsset.Operations.RemoveReference asset.references?.length or 0

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
