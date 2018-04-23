AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Profiles.Profile extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Profiles.Profile'
  @register @id()

  events: ->
    super.concat
      'click .refresh-button': @onClickRefreshButton

  onClickRefreshButton: (event) ->
    profile = @currentData()
    PADB.Profile.adminRefresh profile._id
