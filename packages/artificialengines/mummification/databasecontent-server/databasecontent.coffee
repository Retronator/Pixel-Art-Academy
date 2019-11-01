AM = Artificial.Mummification

Request = request
requestGet = Meteor.wrapAsync Request.get, Request

class AM.DatabaseContent
  @exportGetters = []
  @importTransforms = {}
  @documentImportPriority = {}
  @startupHandlers = []

  @addToExport: (getter) ->
    @exportGetters.push getter

  @addImportDirective: (directive, transform) ->
    @importTransforms[directive] = transform

  @setDocumentImportPriority: (documentId, priority) ->
    @documentImportPriority[documentId] = priority

  @startup: (handler) ->
    @startupHandlers.push handler

  @export: (archive) ->
    console.log "Starting database content export ..."

    directory =
      exportTime: new Date
      documents: {}

    paths = {}

    for getter in @exportGetters
      exportingDocuments = getter()

      for document in exportingDocuments when document?.exportDatabaseContent
        if document.name instanceof Artificial.Babel.Translation
          documentName = document.name.translate().text

        else
          documentName = document.name or document._id

        console.log "Exporting", document.constructor.name, documentName

        {arrayBuffer, path, lastEditTime} = document.exportDatabaseContent()

        console.log "Writing #{Math.round arrayBuffer.length / 1024, 2} kB to #{path}"

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

    # Complete exporting.
    archive.finalize()

    console.log "Database content export done!"

  @import: (directory) ->
    documentIds = _.keys directory.documents
    prioritizedDocumentIds = _.sortBy documentIds, (documentId) => -(@documentImportPriority[documentId] or 0)

    # Create a promise for each updating document so that we can react when all documents have been updated.
    updatePromises = []

    for documentClassId in prioritizedDocumentIds
      documentsInformation = directory.documents[documentClassId]
      documentClass = AM.Document.getClassForId documentClassId

      for documentInformation in documentsInformation
        currentDocument = documentClass.documents.findOne documentInformation._id

        # See how old the document in the database is. If it has no last edit time, assume it's outdated.
        currentLastEditTime = currentDocument?.lastEditTime or new Date 0
        exportedLastEditTime = documentInformation.lastEditTime or directory.exportTime

        # Make sure last edit time isn't a string, but a full date object.
        currentLastEditTime = new Date currentLastEditTime if _.isString currentLastEditTime
        exportedLastEditTime = new Date exportedLastEditTime if _.isString exportedLastEditTime

        # There's nothing to do if the document in the database is already synced with the document on disk.
        continue if currentLastEditTime.getTime() is exportedLastEditTime.getTime()

        if currentLastEditTime < exportedLastEditTime
          # The database document is older so we need to update it.
          do (documentInformation, exportedLastEditTime, documentClass) =>
            updatePromises.push new Promise (resolve, reject) =>
              url = Meteor.absoluteUrl "databasecontent/#{documentInformation.path}"

              requestGet url, encoding: null, (error, response, body) =>
                if error
                  console.error "Error retrieving database content file at url", url
                  resolve()
                  return

                # Retrieve document from the data.
                console.log "Importing", documentInformation.path
                importedDocument = documentClass.importDatabaseContent body, documentInformation

                unless importedDocument
                  console.error "Couldn't extract document from file at url", url
                  resolve()
                  return

                if importedDocument._databaseContentImportDirective
                  transform = @importTransforms[importedDocument._databaseContentImportDirective]
                  delete importedDocument._databaseContentImportDirective
                  transform importedDocument

                # Transform can skip importing a document by deleting the _id field.
                unless importedDocument._id
                  console.log "Skipping import of document with path", documentInformation.path
                  resolve()
                  return

                # Add last edit time if needed so that documents don't need unnecessary imports.
                unless importedDocument.lastEditTime and importedDocument.lastEditTime >= exportedLastEditTime
                  importedDocument.lastEditTime = exportedLastEditTime

                documentClass.documents.upsert importedDocument._id, importedDocument

                console.log "Updated database content with path", documentInformation.path
                resolve()

        else
          # The database document is newer so we should avoid overwriting new content.
          console.warn "Document #{documentClassId}:#{documentInformation._id} at #{documentInformation.path} has been updated since the export."

    Promise.all(updatePromises).then =>
      console.log "Database content initialized."

      # All documents have been updated, notify the database content has started.
      handler() for handler in @startupHandlers
