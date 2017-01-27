AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.reprocessSubmissions': ->
    RA.authorizeAdmin()

    submissions = PADB.PixelDailies.Submission.documents.find(
      processingError:
        $exists: true
    ).fetch()

    console.log "Reprocessing Pixel Dailies submissions with errors. Total:", submissions.length

    count = 0

    for submission in submissions
      PADB.PixelDailies.processTweet submission.tweetData
      
      submission = PADB.PixelDailies.Submission.documents.findOne submission._id
      
      count++ unless submission.processingError

    console.log "#{count} submissions were successfully corrected."
