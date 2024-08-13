AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.PersistentCollection extends AM.Collection
  constructor: (documentClass) ->
    super null, transform: (document) => new documentClass document
    
    @documentClass = documentClass
  
    @find({}).observe
      added: (document) => Persistence.added document
      changed: (document) => Persistence.changed document
      removed: (document) => Persistence.removed document

  insert: (document) ->
    throw new AE.ArgumentException "A persistent collection insert of a profiled #{@documentClass.name} document must have the last edit time." if document.profileId and not document.lastEditTime
  
    super arguments...

  update: (selector, modifier) ->
    # Note: Updates can happen both as normal updates and as upserts. If it's a normal update, we should check if the
    # document is persistent to begin with. In case of upserts, the $set property of the modifier will not be present
    # and it should be a direct field of the document (sent as the modifier).
    document = @findOne selector
    persistenceRequired = document?.profileId or modifier.profileId
    lastEditTimePresent = modifier.$set?.lastEditTime or modifier.lastEditTime
    throw new AE.ArgumentException "A persistent collection update of a profiled #{@documentClass.name} document must set the last edit time." if persistenceRequired and not lastEditTimePresent
    
    super arguments...
