AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Profiles.Scripts extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Profiles.Scripts'
  @register @id()

  @refreshAll: new AB.Method name: "#{@id()}.refreshAll"
  @twitterRefreshAll: new AB.Method name: "#{@id()}.twitterRefreshAll"

  events: ->
    super(arguments...).concat
      'click .refresh-all-button': @onClickRefreshAllButton
      'click .refresh-one-day-button': @onClickRefreshOneDayButton
      'click .twitter-refresh-all-button': @onClickTwitterRefreshAllButton
      'click .twitter-refresh-one-day-button': @onClickTwitterRefreshOneDayButton

  onClickRefreshAllButton: (event) ->
    @constructor.refreshAll()

  onClickRefreshOneDayButton: (event) ->
    oneDayAgo = new Date Date.now() - 60 * 1000 * 1000 * 24
    @constructor.refreshAll oneDayAgo

  onClickTwitterRefreshAllButton: (event) ->
    @constructor.twitterRefreshAll()

  onClickTwitterRefreshOneDayButton: (event) ->
    oneDayAgo = new Date Date.now() - 60 * 1000 * 1000 * 24
    @constructor.twitterRefreshAll oneDayAgo
