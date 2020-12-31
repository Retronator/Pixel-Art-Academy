LOI = LandsOfIllusions

class Migration extends Document.MinorMigration
  name: "Add game time to game state."

  forward: (document, collection, currentSchema, newSchema) =>
    count = collection.update
      _schema: currentSchema
      'state.gameTime':
        $exists: false
    ,
      $set:
        'state.gameTime': 0
        _schema: newSchema
    ,
      multi: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = collection.update
      _schema: currentSchema
      'state.gameTime':
        $exists: true
    ,
      $set:
        _schema: oldSchema
      $unset:
        'state.gameTime': true
    ,
      multi: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts
    
LOI.GameState.addMigration new Migration()
