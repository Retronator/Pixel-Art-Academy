AM = Artificial.Mirage
E1 = PixelArtAcademy.Season1.Episode1

class E1.Pages.Admin.Admissions extends AM.Component
  @register 'PixelArtAcademy.Season1.Episode1.Pages.Admin.Admissions'

  events: ->
    super(arguments...).concat
      'click .process-applied': => Meteor.call 'PixelArtAcademy.Season1.Episode1.Pages.Admin.Admissions.processApplied'
