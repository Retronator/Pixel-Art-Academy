AE = Artificial.Everywhere
AM = Artificial.Mummification
PADB = PixelArtDatabase

PADB.Profile.create = (options) ->
  # Let's see if we were provided with the platform type and username.
  if options.platformType and options.username
    switch options.platformType
      when PADB.Profile.PlatformTypes.Twitter
        profileData = PADB.Profile.Providers.Twitter.createProfileData username: options.username

  throw new AE.ArgumentException "Profile could not be created with provided options." unless profileData

  # Create the artist if it was not provided.
  options.artist ?= PADB.Artist.createFromProfile profileData

  profileData.artist =
    _id: options.artist._id
    
  profileData.lastUpdated = new Date()

  profileId = PADB.Profile.documents.insert profileData

  # Return the new document.
  PADB.Profile.documents.findOne profileId

PADB.Profile.refresh = (profileId, sourceData) ->
  profile = PADB.Profile.documents.findOne profileId
  throw new AE.ArgumentException "Profile does not exist." unless profile

  # If we weren't passed in source data, refresh by username.
  if sourceData
    options = {sourceData}

  else
    options = username: profile.username

  switch profile.platformType
    when PADB.Profile.PlatformTypes.Twitter
      profileData = PADB.Profile.Providers.Twitter.createProfileData options

  profileData.lastUpdated = new Date()

  PADB.Profile.documents.update profileId, $set: profileData
