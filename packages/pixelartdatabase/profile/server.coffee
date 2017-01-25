AE = Artificial.Everywhere
AM = Artificial.Mummification
PADB = PixelArtDatabase

PADB.Profile.create = (options) ->
  # Let's see if we were provided with the platform type and username.
  if options.platformType and options.username
    switch options.platformType
      when PADB.Profile.PlatformTypes.Twitter
        profile = PADB.Profile.Providers.Twitter.createProfileData username: options.username

  throw new AE.ArgumentException 'Profile could not be created with provided options.' unless profile

  # Create the artist if it was not provided.
  options.artist ?= PADB.Artist.createFromProfile profile

  profile.artist =
    _id: options.artist._id

  profileId = PADB.Profile.documents.insert profile

  # Return the new document.
  PADB.Profile.documents.findOne profileId
