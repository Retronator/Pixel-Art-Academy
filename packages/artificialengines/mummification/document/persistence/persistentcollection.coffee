AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.PersistentCollection extends Mongo.Collection
  constructor: (documentClass) ->
    super null, transform: (document) => new documentClass document
    
    @documentClass = documentClass
  
    @find({}).observe
      added: (document) => Persistence.added document
      changed: (document) => Persistence.changed document
      removed: (document) => Persistence.removed document

  insert: (document) ->
    throw new AE.ArgumentException "A persistent collection insert of a profiled document must have the last edit time." if document.profileId and not document.lastEditTime
  
    super arguments...

  update: (selector, modifier) ->
    throw new AE.ArgumentException "A persistent collection update must set the last edit time." unless modifier.$set?.lastEditTime
    
    super arguments...
