PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Mixins.RetireMissingSubmissions
  constructor: (@component) ->

  onCreated: ->
    @_reportedResourceUrls = []

    @_onResourceError = (event) =>
      resourceElement = event.target
      return unless resourceElement.tagName in ['IMG', 'VIDEO']
      return unless @_resourceBelongsToComponent resourceElement

      resourceUrl = resourceElement.currentSrc or resourceElement.src
      @retireMissingSubmissionForResourceUrl resourceUrl

    # Note: We can't do $(document).on since resource error events do not bubble.
    document.addEventListener 'error', @_onResourceError, true

  onDestroyed: ->
    document.removeEventListener 'error', @_onResourceError, true

  _resourceBelongsToComponent: (resourceElement) ->
    return false unless @component.isRendered()

    for componentElement in @component.$children().toArray()
      return true if componentElement is resourceElement or componentElement.contains resourceElement

    false

  retireMissingSubmissionForResourceUrl: (resourceUrl) ->
    return unless resourceUrl

    # Find the submission represented by the failed image or video resource.
    submission = PADB.PixelDailies.Submission.documents.findOne
      $or: [
        'images.imageUrl': resourceUrl
      ,
        'images.videoUrl': resourceUrl
      ]

    # A submission might only be available as a denormalized reference on its theme.
    unless submission
      theme = PADB.PixelDailies.Theme.documents.findOne
        $or: [
          'topSubmissions.images.imageUrl': resourceUrl
        ,
          'topSubmissions.images.videoUrl': resourceUrl
        ]

      submission = _.find theme?.topSubmissions, (topSubmission) =>
        _.find topSubmission.images, (image) =>
          image.imageUrl is resourceUrl or image.videoUrl is resourceUrl

    return unless submission
    return if resourceUrl in @_reportedResourceUrls

    # Avoid repeated HEAD requests when the same resource appears in multiple elements.
    @_reportedResourceUrls.push resourceUrl
    PADB.PixelDailies.Submission.retireMissingSubmission submission._id, resourceUrl
