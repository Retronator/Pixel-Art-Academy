LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Move activeProjectIds to Project thing for Snake, Pinball, and Invasion."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0
    
    oldSnakeAddress = 'state.things.PixelArtAcademy.Pico8.Cartridges.Snake.activeProjectId'
    newSnakeAddress = 'state.things.PixelArtAcademy.Pico8.Cartridges.Snake.Project.activeProjectId'
    
    oldInvasionAddress = 'state.things.PixelArtAcademy.Pico8.Cartridges.Invasion.activeProjectId'
    newInvasionAddress = 'state.things.PixelArtAcademy.Pico8.Cartridges.Invasion.Project.activeProjectId'
    
    oldPinballAddress = 'state.things.PixelArtAcademy.Pixeltosh.Programs.Pinball.activeProjectId'
    newPinballAddress = 'state.things.PixelArtAcademy.Pixeltosh.Programs.Pinball.Project.activeProjectId'
    
    collection.findEach
      _schema: currentSchema
      $or: [
        "#{oldSnakeAddress}": $exists: true
      ,
        "#{oldInvasionAddress}": $exists: true
      ,
        "#{oldPinballAddress}": $exists: true
      ]
    ,
      (document) =>
        mapping =
          "#{oldSnakeAddress}": newSnakeAddress
          "#{oldInvasionAddress}": newInvasionAddress
          "#{oldPinballAddress}": newPinballAddress

        for oldAddress, newAddress of mapping
          continue unless activeProjectId = _.nestedProperty document, oldAddress
          _.deleteNestedProperty document, oldAddress
          _.nestedProperty document, newAddress, activeProjectId

        updated = collection.update
          _id: document._id
        ,
          $set:
            state: document.state
            _schema: newSchema
      
        count += updated
  
    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
