AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.updateUserStatistics': ->
    RA.authorizeAdmin()

    profiles = PADB.Profile.documents.find(
      platformType: PADB.Profile.PlatformTypes.Twitter
    ).fetch()

    console.log "Reprocessing Twitter profiles. Total:", profiles.length

    count = 0

    try
      for profile in profiles
        PADB.PixelDailies.Submission.updateUserStatistics profile.username

        count++

    catch error
      console.log "Something went wrong.", error

    console.log "#{count} profiles were successfully updated."
