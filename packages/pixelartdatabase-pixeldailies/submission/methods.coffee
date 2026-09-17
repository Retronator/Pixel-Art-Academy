PADB = PixelArtDatabase

resourceUrlCheckLifetime = 60 * 60 * 1000
resourceUrlChecksCleanupInterval = 60 * 1000

resourceUrlChecks = {}
lastResourceUrlChecksCleanupTime = 0

cleanupExpiredResourceUrlChecks = (currentTime) ->
  return if currentTime - lastResourceUrlChecksCleanupTime < resourceUrlChecksCleanupInterval

  for checkedResourceUrl, resourceUrlCheck of resourceUrlChecks when resourceUrlCheck.expiresAt <= currentTime
    delete resourceUrlChecks[checkedResourceUrl]

  lastResourceUrlChecksCleanupTime = currentTime

retireSubmission = (submissionId) ->
  PADB.PixelDailies.Submission.documents.update submissionId,
    $set:
      processingError: PADB.PixelDailies.Submission.ProcessingError.ImagesNotFound

  true

PADB.PixelDailies.Submission.retireMissingSubmission.method (submissionId, resourceUrl) ->
  check submissionId, Match.DocumentId
  check resourceUrl, Match.Optional String

  submission = PADB.PixelDailies.Submission.documents.findOne submissionId,
    fields:
      images: 1
      processingError: 1

  return false unless submission
  return true if submission.processingError is PADB.PixelDailies.Submission.ProcessingError.ImagesNotFound

  resourceUrls = for image in submission.images or []
    [image.imageUrl, image.videoUrl]

  resourceUrls = _.compact _.flatten resourceUrls

  # Only check a client-reported resource if it belongs to this submission.
  return false if resourceUrl and resourceUrl not in resourceUrls

  resourceUrl ?= submission.images?[0]?.imageUrl
  return false unless resourceUrl

  currentTime = Date.now()
  cleanupExpiredResourceUrlChecks currentTime

  # Reuse the result of recent checks. Recording the URL before the request also prevents another
  # method invocation from starting the same request while this fiber is waiting for its response.
  if resourceUrlCheck = resourceUrlChecks[resourceUrl]
    return retireSubmission submissionId if resourceUrlCheck.missing
    return false

  resourceUrlChecks[resourceUrl] =
    expiresAt: currentTime + resourceUrlCheckLifetime
    missing: false

  # Confirm the resource is unavailable on the server before retiring the submission.
  # A client-side resource error can also be caused by a temporary network or browser failure.
  try
    HTTP.call 'HEAD', resourceUrl, timeout: 5000

  catch error
    if error.response
      console.log "Submission", submissionId, "returned error", error.response.statusCode

      # Twitter returns both 403 Forbidden and 404 Not Found when media is no longer available.
      if error.response.statusCode in [403, 404]
        resourceUrlChecks[resourceUrl].missing = true
        return retireSubmission submissionId

    else
      console.log "Unknown error for submission", submissionId, error
      throw error

  false
