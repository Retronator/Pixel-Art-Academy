RA = Retronator.Accounts
RS = Retronator.Store

Document.startup ->
  return if Meteor.settings.startEmpty

  # RETRONATOR ITEMS

  RS.Item.create
    catalogKey: RS.Items.CatalogKeys.Retronator.Admin
    name: "Retronator Administrator"
    description: "You are the boss."
