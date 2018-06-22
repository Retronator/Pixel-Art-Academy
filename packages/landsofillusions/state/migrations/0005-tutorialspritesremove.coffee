LOI = LandsOfIllusions

class Migration extends Document.PatchMigration
  name: "Remove tutorial assets where sprite changed to force replay."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    assetsAddress = 'readOnlyState.things.PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics.assets'

    collection.findEach
      _schema: currentSchema
      "#{assetsAddress}": $exists: true
    ,
      (document) =>
        assets = _.nestedProperty document, assetsAddress

        # Remove changed tutorial assets.
        for tutorial in ['Pencil', 'Shortcuts']
          _.remove assets, (asset) => asset.id is "PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics.#{tutorial}"

        updated = collection.update
          _id: document._id
        ,
          $set:
            readOnlyState: document.readOnlyState
            _schema: newSchema

        count += updated

    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
