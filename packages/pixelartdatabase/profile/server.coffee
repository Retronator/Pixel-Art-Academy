AM = Artificial.Mummification
PADB = PixelArtDatabase

# Finds or creates a profile.
PADB.Profile.get = (query) ->
  profile = PADB.Profile.documents.findOne query
  return profile if profile
  
  # It looks like the profile hasn't been made yet, so create it.

  # Let's see if we were provided with the platform type and username.
  if query.platformType and query.username
    switch query.platformType
      when PADB.Profile.PlatformTypes.Twitter
        profile = PADB.Profile.Providers.Twitter.createProfile username: query.username

        PADB.Profile.documents.insert profile if profile

  # Also try to get the artist so that it gets created on the profile.
  profile = PADB.Profile.documents.findOne query
  return unless profile

  PADB.Artist.get
    'profiles._id': profile._id

  # Find the new document, if it was made.
  PADB.Profile.documents.findOne query
