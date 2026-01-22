AM = Artificial.Mummification

Pako = require 'pako'
TextEncoder = require('text-encoder-lite').TextEncoderLite
Request = request

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class AM.DatabaseContent extends AM.DatabaseContent
  @exportGetters = []
  @importTransforms = {}
  @documentImportPriority = {}
  @startupHandlers = []
  
  @setAssets: (@assets) ->

  @addToExport: (getter) ->
    @exportGetters.push getter

  @addImportDirective: (directive, transform) ->
    @importTransforms[directive] = transform

  @setDocumentImportPriority: (documentId, priority) ->
    @documentImportPriority[documentId] = priority

  @startup: (handler) ->
    @startupHandlers.push handler

  @export: (archive, append) ->
    console.log "Starting database content export #{if append then "in append mode" else ""}..."

    if privateDirectoryJson = AM.DatabaseContent.assets.getText AM.DatabaseContent.directoryUrl
      currentPrivateDirectory = EJSON.parse privateDirectoryJson
      console.log "Retrieved current directory."

      # Create a map of documents.
      currentDirectoryDocumentsMap = {}

      for documentClassId, informationDocuments of currentPrivateDirectory.documents
        currentDirectoryDocumentsMap[documentClassId] = {}

        console.log "Building map for #{informationDocuments.length} documents of #{documentClassId}."

        for informationDocument in informationDocuments
          currentDirectoryDocumentsMap[documentClassId][informationDocument._id] = informationDocument

    exportTime = new Date
    
    privateDirectory =
      exportTime: exportTime
      documents: {}
    
    publicDirectory =
      exportTime: exportTime
      documents: {}
      
    paths = {}
    notChangedCount = 0
    encoder = new TextEncoder
  
    for getter in @exportGetters
      exportingDocuments = getter()

      for document in exportingDocuments when document?.getDatabaseContent
        # Get document name.
        if document.name instanceof Artificial.Babel.Translation
          documentName = document.name.translate().text

        else
          documentName = document.name or document._id

        # See if we have the document in the current directory.
        documentClassId = document.constructor.id()
        existingInformationDocument = currentDirectoryDocumentsMap?[documentClassId]?[document._id]
        
        shouldExport = true
    
        if existingInformationDocument?.path and existingInformationDocument?.lastEditTime?.getTime() is document.lastEditTime?.getTime()
          path = existingInformationDocument.path
          publicPath = "#{path.substring 0, path.lastIndexOf '.'}.gzip"
          shouldExport = false
  
          # Load the data directly from the exported files. If any of them are missing, force a re-export.
          publicUrl = "databasecontent/#{publicPath}"
          documentResponse = Request.getSync Meteor.absoluteUrl(publicUrl), encoding: null
          contentType = documentResponse.response.headers['content-type']
          
          if _.startsWith(contentType, 'application/gzip') or _.startsWith(contentType, 'application/octet-stream')
            publicData = documentResponse.body
    
            privateUrl = "databasecontent/#{path}"
          
            try
              privateData = AM.DatabaseContent.assets.getBinary privateUrl
              
              lastEditTime = existingInformationDocument.lastEditTime
    
              notChangedCount++
          
            catch error
              # The document was removed from the private folder so we should export it again.
              shouldExport = true
              
          else
            shouldExport = true

        if shouldExport
          console.log "Exporting", document.constructor.name, documentName

          {plainData, arrayBuffer, path, lastEditTime} = document.getDatabaseContent()

          console.log "Writing #{Math.round arrayBuffer.length / 1024, 2} kB to #{path}"
          
          # Compress plain data.
          binaryPlainData = encoder.encode EJSON.stringify plainData
          publicData = Pako.gzip binaryPlainData, compressionOptions
          
          privateData = arrayBuffer

        # Add a suffix if another document already had this path.
        paths[path] ?= 0
        paths[path]++

        if paths[path] > 1
          nameParts = path.split '.'
          path = "#{nameParts[0]}-#{paths[path]}.#{nameParts[1..].join '.'}"
    
        publicPath = "#{path.substring 0, path.lastIndexOf '.'}.gzip"
    
        # Store information document in directory.
        privateInformationDocument = {path, lastEditTime, _id: document._id}
        publicInformationDocument = {path: publicPath, lastEditTime, _id: document._id}
  
        # Add any extra fields required for querying the directory.
        if document.constructor.databaseContentInformationFields
          for field of document.constructor.databaseContentInformationFields
            publicInformationDocument[field] = document[field]

        privateDirectory.documents[documentClassId] ?= []
        privateDirectory.documents[documentClassId].push privateInformationDocument
        
        publicDirectory.documents[documentClassId] ?= []
        publicDirectory.documents[documentClassId].push publicInformationDocument

        # Place files in the archive.
        archive.append Buffer.from(privateData), name: "private/databasecontent/#{path}"
        archive.append Buffer.from(publicData), name: "public/databasecontent/#{publicPath}"
        
    if append
      # Go over all the private files that weren't added yet.
      for documentClassId, privateInformationDocuments of currentPrivateDirectory.documents
        for privateInformationDocument in privateInformationDocuments
          continue if _.find privateDirectory.documents[documentClassId], (document) => document._id is privateInformationDocument._id
          
          path = privateInformationDocument.path
          privateUrl = "databasecontent/#{path}"
          
          try
            privateData = AM.DatabaseContent.assets.getBinary privateUrl
            privateDirectory.documents[documentClassId] ?= []
            privateDirectory.documents[documentClassId].push privateInformationDocument
        
            archive.append Buffer.from(privateData), name: "private/databasecontent/#{path}"
            
          catch error
            # The document was removed from the private folder so it will also be removed from the new json directory.
            console.log "Removed", documentClassId, "at", path

    # Place directory in the archive.
    archive.append EJSON.stringify(privateDirectory), name: 'private/databasecontent/directory.json'
    archive.append EJSON.stringify(publicDirectory), name: 'public/databasecontent/directory.json'

    # Complete exporting.
    archive.finalize()

    console.log "#{notChangedCount} documents weren't changed." if notChangedCount
    console.log "Database content export done!"

  @import: (directory) ->
    documentClassIds = _.keys directory.documents
    prioritizedDocumentIds = _.sortBy documentClassIds, (documentClassId) => -(@documentImportPriority[documentClassId] or 0)

    # Create a promise for each updating document so that we can react when all documents have been updated.
    updatePromises = []

    for documentClassId in prioritizedDocumentIds
      informationDocuments = directory.documents[documentClassId]
      documentClass = AM.Document.getClassForId documentClassId

      for informationDocument in informationDocuments
        path = informationDocument.privatePath or informationDocument.path
        url = "databasecontent/#{path}"
        currentDocument = documentClass.documents.findOne informationDocument._id

        # See how old the document in the database is. If it has no last edit time, assume it's outdated.
        currentLastEditTime = currentDocument?.lastEditTime or new Date 0
        exportedLastEditTime = informationDocument.lastEditTime or directory.exportTime

        # Make sure last edit time isn't a string, but a full date object.
        currentLastEditTime = new Date currentLastEditTime if _.isString currentLastEditTime
        exportedLastEditTime = new Date exportedLastEditTime if _.isString exportedLastEditTime

        # There's nothing to do if the document in the database is already synced with the document on disk.
        continue if currentLastEditTime.getTime() is exportedLastEditTime.getTime()

        if currentLastEditTime < exportedLastEditTime
          # The database document is older so we need to update it.
          do (informationDocument, exportedLastEditTime, documentClass, path, url) =>
            updatePromises.push new Promise (resolve, reject) =>
              
              AM.DatabaseContent.assets.getBinary url, (error, arrayBuffer) =>
                if error
                  console.error "Error retrieving database content file at url", url
                  resolve()
                  return
                  
                # Retrieve document from the data.
                console.log "Importing", path
                importedDocument = documentClass.deserializeDatabaseContent arrayBuffer, informationDocument

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
                  console.log "Skipping import of document with path", path
                  resolve()
                  return

                # Add last edit time if needed so that documents don't need unnecessary imports.
                unless importedDocument.lastEditTime and importedDocument.lastEditTime >= exportedLastEditTime
                  importedDocument.lastEditTime = exportedLastEditTime

                documentClass.documents.upsert importedDocument._id, importedDocument

                console.log "Updated database content with path", path
                resolve()

        else
          # The database document is newer so we should avoid overwriting new content.
          console.warn "Document #{documentClassId}:#{informationDocument._id} at #{path} has been updated since the export."

    Promise.all(updatePromises).then =>
      console.log "Database content initialized."

      # All documents have been updated, notify the database content has started.
      handler() for handler in @startupHandlers
