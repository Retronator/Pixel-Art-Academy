AT = Artificial.Telepathy
PADB = PixelArtDatabase

class PADB.Profile.Providers.Twitter
  @createProfile: (options) ->
    throw new AE.InvalidOperationException 'Twitter API is not initialized.' unless AT.Twitter.initialized

    throw new AE.ArgumentNullException 'You must provide the profile username.' unless options.username

    # Query the API.
    data = AT.Twitter.usersLookup
      screen_name: options.username
      include_entities: true

    return unless data?[0]

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
