AM = Artificial.Mirage
AB = Artificial.Babel

class AB.Pages.Admin.Scripts extends AM.Component
  @register 'Artificial.Babel.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .generate-best-translations': => Meteor.call 'Artificial.Babel.Pages.Admin.Scripts.GenerateBestTranslations'
