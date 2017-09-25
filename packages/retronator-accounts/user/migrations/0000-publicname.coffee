RA = Retronator.Accounts

class Migration extends Document.AddGeneratedFieldsMigration
  name: "Adding public name generated field."
  fields: [
    'publicName'
  ]

RA.User.addMigration new Migration()
