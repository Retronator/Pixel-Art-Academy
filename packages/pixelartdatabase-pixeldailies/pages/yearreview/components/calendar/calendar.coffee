AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Calendar extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Calendar'

  # Subscriptions
  @themes: new AB.Subscription name: "#{@componentName()}.themes"

  mixins: -> [@infiniteScroll]

  constructor: (@provider) ->
    super arguments...

    @infiniteScroll = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll
      # Provider can already have a higher limit, so start there.
      step: Math.max 53, @provider.limit()
      windowHeightCounts: 2

    # Indicates that the months are rendering.
    @rendering = new ReactiveField false

    # Months is a skeleton structure that only provides the structure for html elements, but no real data.
    @months = new ReactiveField null

    # Months by year is a persistent structure that tracks which days are visible.
    @monthsByYear = new ReactiveField {}

    # Array of submissions sorted by time.
    @submissions = new ReactiveField null

  onRendered: ->
    super arguments...

    # Match provider and infinite scroll limit.
    @autorun (computation) =>
      # Update how many items the provider should return.
      @provider.limit @infiniteScroll.limit()

    Meteor.setTimeout =>
      # Process submissions.
      @autorun (computation) =>
        submissions = @provider.submissions()
        return unless submissions.length

        # We only want to react to submission changes.
        Tracker.nonreactive =>
          # Sort submissions by time.
          submissions = _.sortBy submissions, 'time'
          @submissions submissions

          firstSubmission = _.first submissions
          lastSubmission = _.last submissions

          startYear = firstSubmission.time.getFullYear()
          monthOffset = firstSubmission.time.getMonth()

          months = []
          monthsByYear = @monthsByYear()

          loop
            firstDay = new Date startYear, monthOffset, 1
            break if firstDay > lastSubmission.time

            firstDayDayOfWeek = firstDay.getDay()

            year = firstDay.getFullYear()
            monthNumber = firstDay.getMonth()

            # Only create the month if we need to. This preserves existing month and day IDs.
            monthsByYear[year] ?= {}
            monthsByYear[year][monthNumber] ?=
              # We provide the _id so that #each does not trash existing months.
              _id: Random.id()
              year: firstDay.getFullYear()
              number: monthNumber

              paddingDays: ('' for i in [0...firstDayDayOfWeek])

              # Create an array of days for this month. It needs to be an array so we can iterate over it with #each.
              days: for dayNumber in [1..AE.DateHelper.daysInMonth(monthNumber, year)]
                # We provide the _id so that #each does not trash existing days.
                _id: Random.id()
                number: dayNumber
                month: monthNumber
                year: year

            months.push monthsByYear[year][monthNumber]

            monthOffset++

          # Populate submissions to corresponding dates.
          for submission in submissions
            year = submission.time.getFullYear()
            monthNumber = submission.time.getMonth()
            dayNumber = submission.time.getDate()

            day = monthsByYear[year][monthNumber].days[dayNumber - 1]
            day.submission = submission

          # Mark that we're rendering.
          @rendering true

          # Wait until loading has had time to render.
          Tracker.afterFlush =>
            # Trigger rendering of the calendar.
            @months months
            @monthsByYear monthsByYear

            # Update infinite scroll with how many submissions we've shown.
            @infiniteScroll.updateCount submissions.length

            # Wait until calendar has rendered.
            Tracker.afterFlush =>
              @rendering false
      100

  monthHasSubmissionsClass: ->
    month = @currentData()

    # Grab latest month data.
    monthsByYear = @monthsByYear()
    month = monthsByYear[month.year][month.number]

    submissionsCount = _.sum _.map month.days, (day) => if day.submission then 1 else 0

    'has-submissions' if submissionsCount

  monthName: ->
    month = @currentData()
    monthDate = new Date 2016, month.number

    monthDate.toLocaleString Artificial.Babel.currentLanguage(),
      month: 'long'

  dayData: ->
    day = @currentData()

    # Grab latest day data.
    monthsByYear = @monthsByYear()
    monthsByYear[day.year][day.month].days[day.number - 1]

  hasSubmissionClass: ->
    day = @currentData()
    'has-submission' if day.submission

  submissionHashtag: ->
    day = @currentData()
    day.submission.theme.hashtags[0]

  submissionImage: ->
    day = @currentData()
    day.submission.images?[0]

  loading: ->
    # We're loading if provider is not ready or we're still rendering the results.
    (not @provider.ready()) or @rendering()

  events: ->
    super(arguments...).concat
      'mouseenter .day': @onMouseenterDay
      'mouseleave .day': @onMouseleaveDay

  onMouseenterDay: (event) ->
    $(event.target).find('video')[0]?.play()

  onMouseleaveDay: (event) ->
    $(event.target).find('video')[0]?.pause()
