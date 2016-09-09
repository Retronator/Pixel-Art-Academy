RA = Retronator.Accounts
RS = Retronator.Store

Meteor.startup ->
  # RETRONATOR ITEMS

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retronator.Admin
    name: "Retronator Administrator"
    description: "You are the boss."
