AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Components.BundleItem extends AM.Component
  @register 'Retronator.Store.Components.BundleItem'

  onCreated: ->
    super

    item = @data()
    @subscribe 'Artificial.Babel.Translation.withId', item.description._id, AB.userLanguagePreference()

  ownedClass: ->
    item = @data()
    user = Retronator.user()

    return unless user

    "owned" if user.hasItem item.catalogKey
