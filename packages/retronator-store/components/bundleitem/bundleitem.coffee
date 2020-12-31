AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Components.BundleItem extends AM.Component
  @register 'Retronator.Store.Components.BundleItem'

  onCreated: ->
    super arguments...

    item = @data()
    AB.Translation.forId.subscribe @, item.description._id, AB.languagePreference()

  ownedClass: ->
    item = @data()
    user = Retronator.user()

    return unless user

    "owned" if user.hasItem item.catalogKey
