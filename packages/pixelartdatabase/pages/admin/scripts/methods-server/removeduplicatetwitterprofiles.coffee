RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.Pages.Admin.Scripts.RemoveDuplicateTwitterProfiles': ->
    RA.authorizeAdmin()

    # Generate a unique list of twitter usernames.
    profiles = PADB.Profile.documents.find(
      platformType: PADB.Profile.PlatformTypes.Twitter
    ,
      fields:
        username: true
        artist: true
    ).fetch()

    usernames = _.uniq _.map profiles, (profile) -> profile.username

    # For each username, find any duplicates.
    for username in usernames
      usernameProfiles = _.filter profiles, (profile) -> profile.username is username

      originalProfile = usernameProfiles[0]

      # Collapse duplicates into the first profile.
      for usernameProfile in usernameProfiles[1..]
        # Each profile should have a duplicate artist, so first substitute those. Make sure they're really different.
        unless usernameProfile.artist._id is originalProfile.artist._id
          PADB.Artist.substituteDocument usernameProfile.artist._id, originalProfile.artist._id

          # Delete the artist that nobody points to now.
          PADB.Artist.documents.remove usernameProfile.artist._id

        # Just in case, substitute profiles as well (although at
        # the time of writing this, we have no profile referrers).
        PADB.Profile.substituteDocument usernameProfile._id, originalProfile._id

        # Delete the duplicate profile.
        PADB.Profile.documents.remove usernameProfile._id

        console.log "Removed duplicate of", username
