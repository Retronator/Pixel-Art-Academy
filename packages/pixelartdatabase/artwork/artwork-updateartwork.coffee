AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions
PADB = PixelArtDatabase

PADB.Artwork.updateArtwork = (artworkId, updatedArtworkData) ->
  # Make sure the profile is one of the authors.
  profileId = LOI.adventure.profileId()
  
  artwork = PADB.Artwork.documents.findOne artworkId
  throw new AE.ArgumentException "Artwork does not exist." unless artwork
  throw new AE.UnauthorizedException "The profile is not the author of this artwork." unless artwork.profileId = profileId
  
  update =
    $set:
      lastEditTime: new Date()
  
  for property, value of updatedArtworkData
    if value?
      update.$set[property] = value
      
    else
      update.$unset ?= {}
      update.$unset[property] = 1
  
  # Update artwork.
  PADB.Artwork.documents.update artworkId, update
