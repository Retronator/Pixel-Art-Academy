AM = Artificial.Mummification
PADB = PixelArtDatabase

# Create the artist based on profile data.
PADB.Artist.createFromProfile = (profileData) ->
  aka = []
  aka.push profileData.displayName if profileData.displayName

  artist =
    aka: aka

  artistId = PADB.Artist.documents.insert artist

  # Return the new document.
  PADB.Artist.documents.findOne artistId
