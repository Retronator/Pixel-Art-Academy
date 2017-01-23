AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Admin.Scripts extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .archive-all-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions'
