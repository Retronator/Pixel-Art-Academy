AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.reprocessProfiles': ->
    RA.authorizeAdmin()

    profiles = PADB.Profile.documents.find(
      platformType: PADB.Profile.PlatformTypes.Twitter
    ).fetch()

    console.log "Reprocessing Twitter profiles. Total:", profiles.length

    count = 0
    missingCount = 0

    try
      for profile in profiles
        if profile.sourceData
          newProfile = PADB.Profile.Providers.Twitter.createProfileData
            sourceData: profile.sourceData

        else if profile.username
          newProfile = PADB.Profile.Providers.Twitter.createProfileData
            username: profile.username

        else
          missingCount++
          continue

        PADB.Profile.documents.update profile._id,
          $set: newProfile

        count++

    catch error
      console.log "Something went wrong.", error

    console.log "#{count} profiles were successfully updated."
    console.log "#{missingCount} profiles didn't have source data or username." if missingCount
