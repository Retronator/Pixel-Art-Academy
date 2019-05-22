AM = Artificial.Mummification

Request = request

class AM.DatabaseContent
  @exportGetters = []
  @importTransforms = {}

  @addToExport: (getter) ->
    @exportGetters.push getter

  @addImportDirective: (directive, transform) ->
    @importTransforms[directive] = transform

  @export: (archive) ->
    directory =
      exportTime: new Date
      documents: {}

    for getter in @exportGetters
      exportingDocuments = getter()

      for document in exportingDocuments when document?.exportDatabaseContent
        {arrayBuffer, path, lastEditTime} = document.exportDatabaseContent()

        documentClassId = document.constructor.id()

        # Store document information in directory.
        documentInformation = {path, lastEditTime, _id: document._id}

        directory.documents[documentClassId] ?= []
        directory.documents[documentClassId].push documentInformation

        # Place file in the archive.
        archive.append Buffer.from(arrayBuffer), name: path

    # Place directory in the archive.
    archive.append EJSON.stringify(directory), name: 'directory.json'

    # Comlete exporting.
    archive.finalize()

  @import: (directory) ->
    for documentClassId, documentsInformation of directory.documents
      documentClass = AM.Document.getClassForId documentClassId

      for documentInformation in documentsInformation
        document = documentClass.documents.findOne documentInformation._id, fields: documentClass.lastEditTimeFields
        currentLastEditTime = document.getLastEditTime()

        # There's nothing to do if the document in the database is already synced with the document on disk.
        continue if currentLastEditTime is documentInformation.lastEditTime

        if currentLastEditTime < documentInformation.lastEditTime
          # The database document is older so we need to update it.
          do (documentInformation, documentClass) ->
            Request.get documentInformation.path, encoding: null, (error, response, body) ->
              # Retrieve document from the data.
              document = documentClass.importDatabaseContent body

              if document._databaseContentImportDirective
                transform = @importTransforms[document._databaseContentImportDirective]
                delete document._databaseContentImportDirective
                transform document

              # Transform can skip importing a document by deleting the _id field.
              return unless document._id

              documentClass.documents.upsert document._id, document

        else
          # The database document is newer so we should avoid overwriting new content.
          console.warn "Document #{documentClassId}:#{documentInformation._id} at #{documentInformation.path} has been updated since the export."
