AE = Artificial.Everywhere
AT = Artificial.Telepathy
RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Pages.Admin.Profiles.Scripts.refreshAll.method (olderThanDate) ->
  check olderThanDate, Match.OptionalOrNull Date
  RA.authorizeAdmin()

  olderThanDate ?= new Date()
  
  # Refresh all profiles older than the given date.
  profiles = PADB.Profile.documents.find(
    $or: [
      lastUpdated: $exists: false
    ,
      lastUpdated: $lt: olderThanDate
    ]
  ,
    fields:
      displayName: true
  ).fetch()

  console.log "Refreshing", profiles.length, "profiles."

  # Refresh one every 5 seconds as to not hit API rate limits.
  profileIndex = 0

  refreshNextProfile = ->
    profile = profiles[profileIndex]
    return unless profile

    PADB.Profile.refresh profile._id

    console.log "Refreshed", profile.displayName

    profileIndex++
    Meteor.setTimeout ->
      refreshNextProfile()
    ,
      5000

  # Start the update.
  refreshNextProfile()

PADB.Pages.Admin.Profiles.Scripts.twitterRefreshAll.method (olderThanDate) ->
  check olderThanDate, Match.OptionalOrNull Date
  RA.authorizeAdmin()

  olderThanDate ?= new Date()

  # Refresh all profiles older than the given date.
  profiles = PADB.Profile.documents.find(
    platformType: PADB.Profile.PlatformTypes.Twitter
    $or: [
      lastUpdated: $exists: false
    ,
      lastUpdated: $lt: olderThanDate
    ]
  ,
    fields:
      username: true
  ).fetch()

  console.log "Refreshing", profiles.length, "Twitter profiles."

  # Refresh 100 profiles every 5 seconds as to not hit API rate limits.
  refreshNextProfiles = ->
    nextProfiles = profiles[...100]
    unless nextProfiles.length
      console.log "Finished refreshing Twitter profiles."
      return

    screenNames = (profile.username for profile in nextProfiles)
    screenNames = screenNames.join ','

    try
      data = AT.Twitter.users.lookupPost
        screen_name: screenNames
        include_entities: true

    catch error
      # Pass through the limit exceeded exception since we should stop processing the requests.
      throw error if error instanceof AE.LimitExceededException

      switch error.code
        when 17
          # None of the users queried were found.
          data = []

        else
          throw error

    missingCount = 0

    for profile in nextProfiles
      sourceData = _.find data, (userData) -> userData.screen_name is profile.username

      # Make sure the user was found.
      if sourceData
        PADB.Profile.refresh profile._id, sourceData

      else
        # We don't have the user anymore. Refresh just by id so that the Twitter error will be saved to the profile.
        PADB.Profile.refresh profile._id
        missingCount++

    console.log "Updated", nextProfiles.length, "Twitter profiles.", missingCount, "do not exist anymore."

    # Process next profiles after delay.
    profiles = profiles[100..]

    Meteor.setTimeout ->
      refreshNextProfiles()
    ,
      5000

  # Start the update.
  refreshNextProfiles()
