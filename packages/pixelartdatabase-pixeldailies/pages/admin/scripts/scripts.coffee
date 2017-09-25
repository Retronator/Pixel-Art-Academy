AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Admin.Scripts extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .process-tweet-history': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.processTweetHistory'
      'click .archive-all-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.archiveAllSubmissions'
      'click .reprocess-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.reprocessSubmissions'
      'click .update-theme-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.updateThemeSubmissions'
      'click .reprocess-profiles': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.reprocessProfiles'
      'click .update-user-statistics': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.updateUserStatistics'
      'click .retire-missing-submissions': => Meteor.call 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.retireMissingSubmissions'
