RA = Retronator.Accounts
RS = Retronator.Store

Document.startup ->
  # RETRONATOR ITEMS

  RS.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retronator.Admin
    name: "Retronator Administrator"
    description: "You are the boss."
