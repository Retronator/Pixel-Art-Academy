AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Scripts extends AM.Component
  @register 'PixelArtDatabase.Pages.Admin.Scripts'

  events: ->
    super(arguments...).concat
      'click .remove-duplicate-twitter-profiles': => Meteor.call 'PixelArtDatabase.Pages.Admin.Scripts.RemoveDuplicateTwitterProfiles'
