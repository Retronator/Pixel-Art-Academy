AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions
PADB = PixelArtDatabase

PADB.Artwork.insert.method (artworkData) ->
  check artworkData, Object

  RA.authorizeAdmin()

  PADB.Artwork.documents.insert artworkData

PADB.Artwork.updateCharacterArtwork.method (characterId, artworkId, updatedArtworkData) ->
  check characterId, Match.DocumentId
  check artworkId, Match.DocumentId
  check updatedArtworkData,
    title: Match.Optional String
    wip: Match.Optional Boolean
    
  # Make sure the character is one of the authors.
  character = LOI.Authorize.characterAction characterId
  artistId = character.artist?._id
  throw new AE.ArgumentException "Character does not have an associated artist." unless artistId
  
  artwork = PADB.Artwork.documents.findOne artworkId
  throw new AE.ArgumentException "Artwork does not exist." unless artwork
  
  matchingAuthor = _.find artwork.authors, (author) -> author._id is artistId
  throw new AE.UnauthorizedException "The character is not the author of this artwork." unless matchingAuthor
  
  update = {}
  
  for property, value of updatedArtworkData
    if value?
      update.$set ?= {}
      update.$set[property] = value
      
    else
      update.$unset ?= {}
      update.$unset[property] = 1
  
  # Update artwork.
  PADB.Artwork.documents.update artworkId, update
