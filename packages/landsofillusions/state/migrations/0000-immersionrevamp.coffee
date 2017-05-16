LOI = LandsOfIllusions

class Migration extends Document.PatchMigration
  name: "Reset Immersion section and Chapter 3 to force replay of it."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      'state.things.PixelArtAcademy.Season1.Episode0.Chapter2.Immersion':
        $exists: true
    ,
      (document) =>
        # Reset Chapter 2 Immersion and whole Chapter 3.
        state = document.state

        _.nestedProperty state, 'things.PixelArtAcademy.Season1.Episode0.Chapter2.Immersion', {}
        _.nestedProperty state, 'things.PixelArtAcademy.Season1.Episode0.Chapter3', {}

        _.nestedProperty state, 'scripts.PixelArtAcademy.Season1.Episode0.Chapter2.Immersion', {}
        _.nestedProperty state, 'scripts.PixelArtAcademy.Season1.Episode0.Chapter3', {}

        # Move out of Construct if necessary.
        if state.currentLocationId is 'LandsOfIllusions.Construct.Loading' or state.currentTimelineId is 'Construct'
          state.currentLocationId = 'Retronator.HQ.Basement'
          state.currentTimelineId = 'RealLife'

        updated = collection.update
          _id: document._id
        ,
          $set:
            state: state
            _schema: newSchema

        count += updated

    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
