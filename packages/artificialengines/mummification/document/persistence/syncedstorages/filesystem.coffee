AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorages.FileSystem extends Persistence.SyncedStorage
  @id: -> 'FileSystem'
  
  constructor: (@options) ->
    super arguments...

    throw new AE.ArgumentNullException 'Relative directory paths must be provided.' unless @options?.relativeDirectoryPath? and @options.relativeBackupDirectoryPath?
  
    @_ready = new ReactiveField false

    @initialize()

  initialize: ->
    applicationPaths = await Desktop.call 'filesystem', 'getApplicationPaths'
    @storagePath = "#{applicationPaths.userData}/#{@options.relativeDirectoryPath}"
    @backupPath = "#{applicationPaths.userData}/#{@options.relativeBackupDirectoryPath}"

    @lastEditTimes =
      "#{Persistence.Profile.id()}": {}
    
    # Send all profiles to persistence.
    profileJsons = await Desktop.call 'filesystem', 'getProfiles', @storagePath
    
    profiles = []
    
    for profileJson in profileJsons
      try
        profile = EJSON.parse profileJson
        
        @lastEditTimes[Persistence.Profile.id()][profile._id] = profile.lastEditTime
  
        profiles.push profile
        
      catch error
        console.error "Error parsing profile JSON.", error, profileJson
    
    Persistence.addProfiles @constructor.id(), profiles
  
    # Listen to loading progress changes.
    Desktop.on 'filesystem', 'getProfileDocumentsProgress', (event, progressValue) =>
      @_onLoadProfileProgress progressValue
  
    @_ready true
    
  ready: -> @_ready()
  
  loadDocumentsForProfileIdInternal: (profileId, options) ->
    console.log "File system synced storage is loading documents for profile", profileId if Persistence.debug

    syncedStorageId = @constructor.id()
  
    documents = {}
    @_onLoadProfileProgress = options.onProgress
    
    try
      unless profileDocumentJsons = await Desktop.fetch 'filesystem', 'getProfileDocuments', 60000, "#{@storagePath}/#{profileId}", "#{@backupPath}/#{profileId}"
        throw new AE.IOException "Unable to get profile documents for ID #{profileId}."
        
    catch error
      if error is 'timeout'
        throw new AE.IOException "Reading the save data for ID #{profileId} took longer than 60 seconds."
        
      else
        throw new AE.IOException error
    
    console.log "Documents retrieved. Parsing JSON …" if Persistence.debug
    
    for documentClassId, documentJsons of profileDocumentJsons when documentClassId isnt Persistence.Profile.id()
      console.log "#{documentJsons.length} documents for class", documentClassId if Persistence.debug

      documents[documentClassId] = {}
      @lastEditTimes[documentClassId] ?= {}
      
      for documentJson in documentJsons
        try
          document = EJSON.parse documentJson
          documents[documentClassId][document._id] = "#{syncedStorageId}": document
          @lastEditTimes[documentClassId][document._id] = document.lastEditTime
      
        catch error
          console.error "Error parsing document JSON.", error, documentJson
    
    console.log "Documents successfully parsed." if Persistence.debug
    documents

  addedInternal: (document) -> @_add document
  changedInternal: (document) -> @_update document
  removedInternal: (document) -> @_delete document

  _add: (document) ->
    @_update document

  _update: (document) ->
    # Check if this is a different version than the one we have.
    documentClassId = document.constructor.id()
    return if EJSON.equals document.lastEditTime, @lastEditTimes[documentClassId]?[document._id]
    
    path = @_getDocumentPath document
    documentJson = EJSON.stringify document.getSourceData()
    error = await Desktop.call 'filesystem', 'writeFile', path, documentJson
    
    if error
      LOI.adventure.showDialogMessage """
        Unfortunately something went wrong with auto-saving the game. It's probably my fault, I'll need to fix this!
        Please restart the game to avoid losing any game progress.
        If you report this bug, this could be of help: #{error.message}
      """
      
      throw new AE.ExternalException "Writing document to the file system failed.", path, error
    
    @lastEditTimes[documentClassId] ?= {}
    @lastEditTimes[documentClassId][document._id] = document.lastEditTime

  _getDocumentPath: (document) ->
    documentClassId = document.constructor.id()
    documentId = document._id
    profileId = document.profileId

    "#{@storagePath}/#{profileId}/#{documentClassId}/#{documentId}.json"

  _delete: (document) ->
    path = @_getDocumentPath document
    Desktop.call 'filesystem', 'deleteFile', path
