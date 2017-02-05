AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Stream extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream'

  mixins: -> [@infiniteScroll]

  constructor: ->
    super

    @infiniteScroll = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll
      step: 10
      windowHeightCounts: 3

  onCreated: ->
    super

    # Update current count for infinite scroll.
    @autorun (computation) =>
      artworks = @data()

      @infiniteScroll.updateCount artworks?.length or 0

  artworkCaptionClass: ->
    @constructor.ArtworkCaption

  class @ArtworkCaption extends AM.Component
    @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream.ArtworkCaption'

    onCreated: ->
      super

      @submission = new ComputedField =>
        artwork = @data()
        return unless artwork

        imageRepresentation = artwork.firstImageRepresentation()

        PADB.PixelDailies.Submission.documents.findOne
          'images.imageUrl': imageRepresentation.url

    title: ->
      return unless submission = @submission()

      lowercaseHashtags = for hashtag in submission.theme?.hashtags or []
        "##{_.toLower hashtag}"

      # Construct a custom ending of the title.
      ending = ''

      # Remove the trailing hashtags, mentions and links.
      title = submission.text.replace /(?:(?:#\S*|@\S*|https.*)(?: |$))+$/, (trailingText) =>
        # Save ending for analysis.
        ending = trailingText

        # Delete it from the text.
        ''

      title = _.trim title

      titleEndsWithFor = _.endsWith title, 'for'

      endingWords = _.split ending, ' '

      endingWords = _.filter endingWords, (endingWord, index) =>
        lowercaseWord = _.toLower endingWord

        # Preserve theme hashtags.
        return true if lowercaseWord in lowercaseHashtags

        # If text ended with for, permit the first @pixel_dailies and #pixel_dailies
        return true if titleEndsWithFor and index is 0 and lowercaseWord.indexOf('pixel_dailies') > -1

        false

      _.trim "#{title} #{endingWords.join ' '}"

    date: ->
      @submission()?.time.toLocaleString Artificial.Babel.userLanguagePreference()[0] or 'en-US',
        month: 'long'
        day: 'numeric'
        year: 'numeric'

    dateUrl: ->
      date = @submission()?.time
      return unless date

      FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day',
        year: date.getFullYear()
        month: _.toLower date.toLocaleString 'en-US', month: 'long'
        day: date.getDate()
