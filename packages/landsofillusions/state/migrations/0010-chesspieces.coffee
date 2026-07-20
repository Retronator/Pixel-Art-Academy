LOI = LandsOfIllusions

class Migration extends Document.PatchMigration
  name: "Fix too many chess pieces bought in Chess Academy."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0
    
    ownedPieceTypeCountsAddress = 'state.things.PixelArtAcademy.Pixeltosh.Programs.Chess.ownedPieceTypeCounts'
    
    Chess = PixelArtAcademy.Pixeltosh.Programs.Chess

    collection.findEach
      _schema: currentSchema
      "#{ownedPieceTypeCountsAddress}": $exists: true
    ,
      (document) =>
        # See if any amount of chess pieces exceeds the maximum.
        ownedPieceTypeCounts = _.nestedProperty document, ownedPieceTypeCountsAddress
        
        changed = false
        
        for pieceType, amount of ownedPieceTypeCounts when amount > Chess.Piece.InfoForType[pieceType].requiredCount
          ownedPieceTypeCounts[pieceType] = Chess.Piece.InfoForType[pieceType].requiredCount
          changed = true
        
        return unless changed
        
        # Remove all Colors assets.
        _.nestedProperty document, ownedPieceTypeCountsAddress, ownedPieceTypeCounts

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
