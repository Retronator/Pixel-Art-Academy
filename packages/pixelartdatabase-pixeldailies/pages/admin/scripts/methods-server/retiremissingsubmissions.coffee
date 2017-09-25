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
        images: 1
    ).fetch()

    console.log "Testing all displayable Pixel Dailies submissions. Total:", submissions.length

    count = 0

    for submission, index in submissions
      # Make an HTTP HEAD request for the first image and see what code we get.
      try
        HTTP.call 'HEAD', submission.images[0].imageUrl

      catch error
        console.log "submission with index", index, "returned error", error.response.statusCode

        # Only react to 404 Not Found errors.
        if error.response.statusCode is 404
          PADB.PixelDailies.Submission.documents.update submission._id,
            $set:
              processingError: PADB.PixelDailies.Submission.ProcessingError.ImagesNotFound

          count++

      console.log "processed", index + 1, "so far" unless (index + 1) % 100

    console.log "#{count} submissions had missing images."
