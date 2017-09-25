AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions': ->
    RA.authorizeAdmin()

    submissionsCursor = PADB.PixelDailies.Submission.documents.find {},
      fields:
        tweetData: 0

    console.log "Archiving all Pixel Dailies submissions. Total:", submissionsCursor.count()

    count = 0
    quit = false

    submissionsCursor.forEach (submission, index) =>
      return if quit

      # Find the twitter profile and listen for rate limit exception.
      try
        PADB.PixelDailies.archiveSubmission submission
        count++

      catch error
        if error instanceof AE.LimitExceededException
          console.log "Twitter API rate limit exceeded. Stopping archiving."
          quit = true
          return

      console.log "processed", index + 1, "so far" unless (index + 1) % 100

    console.log "#{count} submissions were archived."
