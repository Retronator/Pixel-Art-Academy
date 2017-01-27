AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions': ->
    RA.authorizeAdmin()

    submissions = PADB.PixelDailies.Submission.documents.find().fetch()

    console.log "Archiving all Pixel Dailies submissions. Total:", submissions.length

    count = 0

    for submission in submissions
      # Find the twitter profile and listen for rate limit exception.
      try
        PADB.PixelDailies.archiveSubmission submission
        count++

      catch error
        if error instanceof AE.LimitExceededException
          console.log "Twitter API rate limit exceeded. Stopping archiving."
          break

    console.log "#{count} submissions were archived."
