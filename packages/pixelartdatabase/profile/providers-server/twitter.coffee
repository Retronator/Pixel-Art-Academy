AE = Artificial.Everywhere
AT = Artificial.Telepathy
PADB = PixelArtDatabase

class PADB.Profile.Providers.Twitter
  @getByScreenName: (screenName) ->
    # Twitter's screen names are case insensitive so we search for the username with a regex.
    usernameRegex = new RegExp screenName, 'i'
  
    profile = PADB.Profile.documents.findOne
      platformType: PADB.Profile.PlatformTypes.Twitter
      username: usernameRegex
  
    return profile if profile

    # We didn't find the profile, so create it.
    PADB.Profile.create
      platformType: PADB.Profile.PlatformTypes.Twitter
      username: screenName

  @createProfileData: (options) ->
    throw new AE.InvalidOperationException 'Twitter API is not initialized.' unless AT.Twitter.initialized

    throw new AE.ArgumentNullException 'You must provide the profile username.' unless options.username

    # Query the API.
    try
      data = AT.Twitter.usersLookup
        screen_name: options.username
        include_entities: true

    catch error
      # Pass through the limit exceeded exception since we should stop processing the requests.
      throw error if error instanceof AE.LimitExceededException

      switch error.code
        when 17
          # No user was found for the username. Return a profile with the error.
          profile =
            platformType: PADB.Profile.PlatformTypes.Twitter
            username: options.username
            error: error

          return profile

        else
          throw error

    unless data?[0]
      console.error "Error creating profile for twitter user with options", options
      return

    sourceData = data[0]

    # Create the profile out of source data.
    profile =
      platformType: PADB.Profile.PlatformTypes.Twitter
      url: "https://twitter.com/#{sourceData.screen_name}"
      username: sourceData.screen_name
      displayName: sourceData.name
      imageUrl: sourceData.profile_image_url
      description: sourceData.description
      followersCount: sourceData.followers_count
      sourceData: sourceData

    profile
