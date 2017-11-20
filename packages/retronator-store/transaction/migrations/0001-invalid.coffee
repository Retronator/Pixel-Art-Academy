RS = Retronator.Store

class PaymentsMigration extends Document.AddReferenceFieldsMigration
  name: 'Adding invalid field to payments.'

RS.Transaction.addMigration new PaymentsMigration()

class FieldMigration extends Document.AddGeneratedFieldsMigration
  name: "Adding invalid generated field."
  fields: [
    'invalid'
  ]

RS.Transaction.addMigration new FieldMigration()
