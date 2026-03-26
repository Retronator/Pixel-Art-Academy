Facts.setUserIdFilter (userId) ->
  user = Retronator.Accounts.User.documents.findOne userId
  user?.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin
