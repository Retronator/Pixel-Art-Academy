RS = Retronator.Store

class Migration extends Document.AddGeneratedFieldsMigration
  name: "Adding invalid generated field."
  fields: [
    'invalid'
  ]

RS.Payment.addMigration new Migration()
