AM = Artificial.Mummification
PADB = PixelArtDatabase

# Finds or creates a profile.
PADB.Artist.get = (query) ->
  artist = PADB.Artist.documents.findOne query
  return artist if artist
  
  # It looks like the artist hasn't been made yet, so create it.

  # Let's see if we were provided with the profile id.
  if query['profiles._id']
    profile = PADB.Profile.documents.findOne query['profiles._id']
    return unless profile

    # Create the artist based on profile data.
    aka = []
    aka.push profile.displayName if profile.displayName

    artist =
      aka: aka

    artistId = PADB.Artist.documents.insert artist

    # Update the profile to point to this artist.
    PADB.Profile.documents.update profile._id,
      $set:
        artist:
          _id: artistId

  # Find the new document, if it was made.
  PADB.Artist.documents.findOne query
