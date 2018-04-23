LOI = LandsOfIllusions

class Migration extends Document.AddRequiredFieldsMigration
  name: "Adding GameState fields."
  fields:
    stateLastUpdatedAt: new Date()
    readOnlyState: {}
    events: []

LOI.GameState.addMigration new Migration()
