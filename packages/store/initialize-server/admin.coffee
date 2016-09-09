RA = Retronator.Accounts
RS = Retronator.Store

# Admin creation
Meteor.startup ->
  unless Meteor.settings.admin
    console.warn "You need to specify an admin user in the settings file and don't forget to run the server with the --settings flag pointing to it."
    return

  # First check if we already have the admin user.
  adminUsername = Meteor.settings.admin.username
  adminUser = Meteor.users.findOne username: adminUsername

  return if adminUser and adminUser.hasItem RS.Items.CatalogKeys.Retronator.Admin

  # Create a new admin user if necessary.
  adminId = adminUser?._id or Accounts.createUser Meteor.settings.admin

  # Add admin item to admin user.
  adminItem = RA.Transactions.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.Retronator.Admin

  RA.Transactions.Transaction.documents.insert
    time: new Date()
    user:
      _id: adminId
    items: [
      item:
        _id: adminItem._id
    ]
