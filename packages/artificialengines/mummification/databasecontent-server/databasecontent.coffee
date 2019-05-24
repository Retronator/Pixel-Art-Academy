AM = Artificial.Mummification

Request = request
requestGet = Meteor.wrapAsync Request.get, Request

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

    paths = {}

    for getter in @exportGetters
      exportingDocuments = getter()

      for document in exportingDocuments when document?.exportDatabaseContent
        {arrayBuffer, path, lastEditTime} = document.exportDatabaseContent()

        # Add a suffix
        paths[path] ?= 0
        paths[path]++

        if paths[path] > 1
          nameParts = path.split '.'
          path = "#{nameParts[0]}-#{paths[path]}.#{nameParts[1..].join '.'}"

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
    for documentClassId, documentsInformation of directory.documents when documentClassId is Artificial.Babel.Translation.id()
      documentClass = AM.Document.getClassForId documentClassId

      for documentInformation in documentsInformation
        currentDocument = documentClass.documents.findOne documentInformation._id

        # See how old the document in the database is. If it has no last edit time, assume it's outdated.
        currentLastEditTime = currentDocument?.lastEditTime or new Date 0

        # There's nothing to do if the document in the database is already synced with the document on disk.
        continue if currentLastEditTime.getTime() is documentInformation.lastEditTime.getTime()

        if currentLastEditTime < documentInformation.lastEditTime
          # The database document is older so we need to update it.
          do (documentInformation, documentClass) =>
            url = Meteor.absoluteUrl "databasecontent/#{documentInformation.path}"

            requestGet url, encoding: null, (error, response, body) =>
              if error
                console.error "Error retrieving database content file at url", url
                return

              # Retrieve document from the data.
              importedDocument = documentClass.importDatabaseContent body

              unless importedDocument
                console.error "Couldn't extract document from file at url", url
                return

              if importedDocument._databaseContentImportDirective
                transform = @importTransforms[importedDocument._databaseContentImportDirective]
                delete importedDocument._databaseContentImportDirective
                transform importedDocument

              # Transform can skip importing a document by deleting the _id field.
              return unless importedDocument._id

              # Add last edit time if needed so that documents don't need unnecessary imports.
              unless importedDocument.lastEditTime and importedDocument.lastEditTime >= documentInformation.lastEditTime
                importedDocument.lastEditTime = documentInformation.lastEditTime

              documentClass.documents.upsert importedDocument._id, importedDocument

        else
          # The database document is newer so we should avoid overwriting new content.
          console.warn "Document #{documentClassId}:#{documentInformation._id} at #{documentInformation.path} has been updated since the export."
