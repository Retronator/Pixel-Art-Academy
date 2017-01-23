RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  # For all users, call onTransactionsUpdated.
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions': ->
    RA.authorizeAdmin()

    console.log "Archiving all Pixel Dailies submissions."

    count = 0

    PADB.PixelDailies.Submission.documents.find().forEach (submission) ->
      PADB.PixelDailies.archiveSubmission submission
      count++

    console.log "#{count} submissions were archived."
