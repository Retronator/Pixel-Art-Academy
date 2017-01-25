AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  # For all users, call onTransactionsUpdated.
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.rematchMissingThemes': ->
    RA.authorizeAdmin()

    submissions = PADB.PixelDailies.Submission.documents.find(
      processingError: PADB.PixelDailies.Submission.ProcessingError.NoThemeMatch
    ).fetch()

    console.log "Rematching Pixel Dailies submissions. Total:", submissions.length

    count = 0

    for submission in submissions
      PADB.PixelDailies.processTweet submission.tweetData
      
      submission = PADB.PixelDailies.Submission.documents.findOne submission._id
      
      count++ unless submission.processingError

    console.log "#{count} submissions were successfully matched."
