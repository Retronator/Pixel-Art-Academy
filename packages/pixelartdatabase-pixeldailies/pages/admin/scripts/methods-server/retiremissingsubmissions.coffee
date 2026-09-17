AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.retireMissingSubmissions': ->
    RA.authorizeAdmin()

    submissions = PADB.PixelDailies.Submission.documents.find(
      processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition
    ,
      fields:
        _id: 1
    ).fetch()

    console.log "Testing all displayable Pixel Dailies submissions. Total:", submissions.length

    count = 0

    for submission, index in submissions
      # Use the same server-side check that handles missing images reported by clients.
      retired = PADB.PixelDailies.Submission.retireMissingSubmission submission._id
      count++ if retired

      console.log "processed", index + 1, "so far" unless (index + 1) % 100

    console.log "#{count} submissions had missing images."
