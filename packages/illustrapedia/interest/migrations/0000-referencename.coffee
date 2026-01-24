IL = Illustrapedia

class Migration extends Document.AddGeneratedFieldsMigration
  name: "Adding reference name generated field."
  fields: [
    'referenceName'
  ]

IL.Interest.addMigration new Migration()
