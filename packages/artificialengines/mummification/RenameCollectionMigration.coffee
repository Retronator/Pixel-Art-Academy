AM = Artificial.Mummification
  
class AM.RenameCollectionMigration extends Document.MajorMigration
  forward: (document, collection, currentSchema, newSchema) =>
    document.renameCollectionMigration @constructor.old, @constructor.new

    super

  backward: (document, collection, currentSchema, oldSchema) =>
    document.renameCollectionMigration @constructor.new, @constructor.old

    super
