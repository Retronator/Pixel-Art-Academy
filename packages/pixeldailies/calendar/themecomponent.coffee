AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelDailies.ThemeCalendarComponent extends AM.Component
  template: ->
    'PixelArtAcademy.PixelDailies.ThemeCalendarComponent'

  onCreated: ->
    super
    
    theme = @data()

    @showingTopOnly = new ReactiveField true

    @subscribe 'PAA.PixelDailies.Submissions.forTheme', theme._id

  submissions: ->
    theme = @data()

    options =
      sort:
        favoritesCount: -1

    options.limit = 4 if @showingTopOnly()

    PAA.PixelDailies.Submission.documents.find
      'theme._id': theme._id
    ,
      options

  showShowAllButton: ->
    theme = @data()
    count = PAA.PixelDailies.Submission.documents.find('theme._id': theme._id).count()

    # Show the button if we're only showing the top items and there are actually more items to show.
    @showingTopOnly() and count > 4

  events: ->
    super.concat
      'click .show-all': @onClickShowAll

  onClickShowAll: (event) ->
    @showingTopOnly false
