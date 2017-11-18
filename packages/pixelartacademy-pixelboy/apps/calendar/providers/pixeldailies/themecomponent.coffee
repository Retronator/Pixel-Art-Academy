AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy
PADB = PixelArtDatabase

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.PixelDailies.ThemeComponent extends AM.Component
  template: ->
    'PixelArtAcademy.PixelBoy.Apps.Calendar.Providers.PixelDailies.ThemeComponent'

  onCreated: ->
    super
    
    theme = @data()

    @showingTopOnly = new ReactiveField true

    PADB.PixelDailies.Submission.forTheme.subscribe @, theme._id

  submissions: ->
    theme = @data()

    options =
      sort:
        favoritesCount: -1

    options.limit = 4 if @showingTopOnly()

    PADB.PixelDailies.Submission.documents.find
      'theme._id': theme._id
    ,
      options

  showShowAllButton: ->
    theme = @data()
    count = PADB.PixelDailies.Submission.documents.find('theme._id': theme._id).count()

    # Show the button if we're only showing the top items and there are actually more items to show.
    @showingTopOnly() and count > 4

  events: ->
    super.concat
      'click .show-all': @onClickShowAll

  onClickShowAll: (event) ->
    @showingTopOnly false
