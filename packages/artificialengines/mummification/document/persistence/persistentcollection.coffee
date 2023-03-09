AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.PersistentCollection extends Mongo.Collection
  constructor: (documentClass, options) ->
    super null, transform: (document) => new documentClass document
    
    @documentClass = documentClass
  
    @find({}).observe
      added: (document) => Persistence.added document
      changed: (document) => Persistence.changed document
      removed: (document) => Persistence.removed document
