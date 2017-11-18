RA = Retronator.Accounts

class Migration extends Document.ModifyGeneratedFieldsMigration
  name: "Adding patreon to loginServices generated field."
  fields: [
    'loginServices'
  ]

RA.User.addMigration new Migration()
