LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Change sidewaysIndex for Elements of art sideways connections."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    connectionsAddress = 'state.things.PixelArtAcademy.PixelPad.Apps.StudyPlan.goals.PixelArtAcademy_LearnMode_PixelArtFundamentals_Fundamentals_Goals_ElementsOfArt.connections'

    collection.findEach
      _schema: currentSchema
      "#{connectionsAddress}": $exists: true
    ,
      (document) =>
        # Remove changed Basics assets.
        connections = _.nestedProperty document, connectionsAddress
        
        # Connections coming from index 2 should now come from index 1 as there is no more incoming sideways pathways.
        connection.sidewaysIndex = 1 for connection in connections when connection.sidewaysIndex is 2

        # Remove all Colors assets.
        _.nestedProperty document, connectionsAddress, connections

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
