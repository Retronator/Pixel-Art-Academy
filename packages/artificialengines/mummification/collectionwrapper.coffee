AM = Artificial.Mummification

# Helper that creates a local collection out of a reactive source of documents.
class AM.CollectionWrapper
  constructor: (documentsFunction) ->
    collectionWrapper = new Mongo.Collection null

    # Reactively update documents in the collection.
    currentDocumentIds = []

    updateAutorun = Tracker.autorun (computation) ->
      newDocuments = documentsFunction()
      newDocumentIds = (document._id for document in newDocuments)

      # Insert or update new documents.
      for document in newDocuments
        if document._id in currentDocumentIds
          collectionWrapper.update document._id, document

        else
          collectionWrapper.insert document

      # Remove old documents that aren't present anymore.
      for documentId in currentDocumentIds when not documentId in newDocumentIds
        collectionWrapper.remove documentId

      currentDocumentIds = newDocumentIds

    collectionWrapper.stop = ->
      updateAutorun.stop()

    return collectionWrapper
