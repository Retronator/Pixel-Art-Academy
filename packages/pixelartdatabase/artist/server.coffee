AM = Artificial.Mummification
AE = Artificial.Everywhere
PADB = PixelArtDatabase

PADB.Artist.create = (documentData) ->
  artistQuery = {}

  if documentData.name
    # We use the name field as the signature to fully identify the artist.
    for key, value of documentData.name
      artistQuery["name.#{key}"] = value

  else if documentData.pseudonym
    # Some artists are only known under their pseudonym
    artistQuery.pseudonym = documentData.pseudonym

  artists = PADB.Artist.documents.fetch artistQuery

  # TODO: If we have multiple artists that match the query, we'll need to resolve this in another way.
  if artists.length > 1
    console.error "Multiple artists were found with this query.", artistQuery
    return

  if artists.length is 1
    artist = artists[0]
    artistId = artist._id

    # Override old with new data. We have to manually merge the aka array.
    documentData.aka = _.union artist.aka, documentData.aka if documentData.aka
    
    # We need to manually merge existing name fields.
    _.defaults documentData.name, artist.name

    _.extend artist, documentData

    # Update the artist in the database.
    PADB.Artist.documents.update artistId, artist

  else
    # This is a new artist, we can simply insert them.
    artistId = PADB.Artist.documents.insert documentData

  # Return the new document.
  PADB.Artist.documents.findOne artistId

# Create the artist based on profile data.
PADB.Artist.createFromProfile = (profileData) ->
  aka = []
  aka.push profileData.displayName if profileData.displayName

  artist =
    aka: aka

  artistId = PADB.Artist.documents.insert artist

  # Return the new document.
  PADB.Artist.documents.findOne artistId
