AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorages
  loadInternal: (documentClass, documentId, callback) ->
    # Override and return a promise that will resolve with the loaded document.
    throw new AE.NotImplementedException "You must provide a way to load a document from the storage."
  
  saveInternal: (document, callback) ->
    # Override and return a promise that will resolve when the document was saved.
    throw new AE.NotImplementedException "You must provide a way to save a document to storage."
  
  deleteInternal: (document, callback) ->
    # Override and return a promise that will resolve when the document was deleted.
    throw new AE.NotImplementedException "You must provide a way to delete a document from storage."
