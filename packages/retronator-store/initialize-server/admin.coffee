RS = Retronator.Store

# Admin creation
Document.startup ->
  return if Meteor.settings.startEmpty

  unless Meteor.settings.admin
    console.warn "Set admin user info in the settings file if you want to have an admin user automatically created for you."
    return

  # First check if we already have the admin user.
  adminUsername = Meteor.settings.admin.username
  adminUser = Meteor.users.findOne username: adminUsername

  return if adminUser and adminUser.hasItem RS.Items.CatalogKeys.Retronator.Admin

  # Create a new admin user if necessary.
  adminId = adminUser?._id or Accounts.createUser Meteor.settings.admin

  # Add admin item to admin user.
  adminItem = RS.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.Retronator.Admin

  RS.Transaction.documents.insert
    time: new Date()
    user:
      _id: adminId
    items: [
      item:
        _id: adminItem._id
    ]
