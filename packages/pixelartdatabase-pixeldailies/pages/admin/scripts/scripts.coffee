AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Admin.Scripts extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .archive-all-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions'
      'click .rematch-missing-themes': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.rematchMissingThemes'
      'click .update-theme-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.updateThemeSubmissions'
