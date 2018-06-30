LOI = LandsOfIllusions

class Migration extends Document.PatchMigration
  name: "Remove tutorial assets where sprite changed to force replay."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    assetsAddress = 'readOnlyState.things.PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial'

    collection.findEach
      _schema: currentSchema
      "#{assetsAddress}": $exists: true
    ,
      (document) =>
        # Remove changed Basics assets.
        basicsAssets = _.nestedProperty document, "#{assetsAddress}.Basics.assets"

        for tutorial in ['Pencil', 'Shortcuts']
          _.remove basicsAssets, (asset) => asset.id is "#{assetsAddress}.Basics.#{tutorial}"

        # Remove all Colors assets.
        _.nestedProperty document, "#{assetsAddress}.Colors.assets", []

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
