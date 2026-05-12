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

    @lastEditTimes = {}
    
    # Send all profiles to persistence.
    profileJsons = await Desktop.call 'filesystem', 'getProfiles', @storagePath
    
    profiles = []
    
    for profileJson in profileJsons
      try
        profiles.push EJSON.parse profileJson
        
      catch error
        console.error "Error parsing profile JSON.", error, profileJson
    
    Persistence.addProfiles @constructor.id(), profiles
  
    # Listen to loading progress changes. Note: We wire this only once since SteamCloud inherits from FileSystem.
    unless Persistence.SyncedStorages.FileSystem._getProfileDocumentsProgressWired
      Desktop.on 'filesystem', 'getProfileDocumentsProgress', (event, progressValue) ->
        Persistence.SyncedStorages.FileSystem._onLoadProfileProgress? progressValue * 0.5
      
      Persistence.SyncedStorages.FileSystem._getProfileDocumentsProgressWired = true
  
    @_ready true
    
  ready: -> @_ready()
  
  loadDocumentsForProfileIdInternal: (profileId, options) ->
    console.log "File system synced storage is loading documents for profile", profileId if Persistence.debug

    syncedStorageId = @constructor.id()
  
    documents = {}
    Persistence.SyncedStorages.FileSystem._onLoadProfileProgress = options.onProgress
    
    try
      unless profileDocumentJsons = await Desktop.fetch 'filesystem', 'getProfileDocuments', 60000, "#{@storagePath}/#{profileId}", "#{@backupPath}/#{profileId}"
        throw new AE.IOException "Unable to get profile documents for ID #{profileId}."
        
    catch error
      if error is 'timeout'
        throw new AE.IOException "Reading the save data for ID #{profileId} took longer than 60 seconds."
        
      else
        throw new AE.IOException error
    
    console.log "Documents retrieved. Parsing JSON …" if Persistence.debug
    
    @lastEditTimes = {}
    
    documentsCount = 0
    documentsParsedCount = 0
    reportedProgress = 0
    
    for documentClassId, documentJsons of profileDocumentJsons
      for documentName of documentJsons
        documentsCount++
    
    for documentClassId, documentJsons of profileDocumentJsons
      console.log "#{documentJsons.length} documents for class", documentClassId if Persistence.debug

      documents[documentClassId] = {}
      @lastEditTimes[documentClassId] ?= {}
      
      for documentName, documentJson of documentJsons
        try
          document = EJSON.parse documentJson
          documents[documentClassId][document._id] = "#{syncedStorageId}": document unless documentClassId is Persistence.Profile.id()
          @lastEditTimes[documentClassId][document._id] = document.lastEditTime
      
        catch error
          console.error "Error parsing document JSON for", documentClassId, documentName, error
          console.log "JSON content", documentJson
        
        documentsParsedCount++
        progress = 0.5 + documentsParsedCount / documentsCount * 0.5
        
        # Report progress only when it would make a difference in the display.
        if progress >= reportedProgress + 0.01 or progress is 1
          options.onProgress? progress
          reportedProgress = progress
          
          # Give the display a chance to update.
          await _.waitForNextFrame()
    
    console.log "Documents successfully parsed." if Persistence.debug
    documents

  addedInternal: (document) -> @_save document
  changedInternal: (document) -> @_save document
  removedInternal: (document) -> @_delete document

  _save: (document) ->
    # Check if this is a different version than the one we have.
    documentClassId = document.constructor.id()
    return if EJSON.equals document.lastEditTime, @lastEditTimes[documentClassId]?[document._id]
    
    path = @_getDocumentPath document
    documentJson = EJSON.stringify document.getSourceData()
    error = await Desktop.fetch 'filesystem', 'writeFile', 60000, path, documentJson
    
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
    if document instanceof Persistence.Profile
      # Profiles get backed up and their directory fully removed.
      profileId = document._id
      
      try
        unless backupSucceeded = await Desktop.fetch 'filesystem', 'backupProfile', 60000, "#{@storagePath}/#{profileId}", "#{@backupPath}/#{profileId}"
          throw new AE.IOException "Unable to backup profile #{profileId}."
      
      catch error
        LOI.adventure.showDialogMessage """
          Removing a profile encountered an error during final backup.
          If you report this bug, this could be of help: #{error.message}
        """
        
        throw new AE.ExternalException "Backing up profile directory from the file system failed.", path, error
      
      try
        unless removeSucceeded = await Desktop.fetch 'filesystem', 'removeProfile', 60000, "#{@storagePath}/#{profileId}"
          throw new AE.IOException "Unable to remove profile #{profileId}."
        
        @lastEditTimes = {}
      
      catch error
        LOI.adventure.showDialogMessage """
          Removing a profile encountered an error during directory removal.
          If you report this bug, this could be of help: #{error.message}
        """
        
        throw new AE.ExternalException "Removing the profile directory from the file system failed.", path, error
    
    else
      path = @_getDocumentPath document
      await Desktop.fetch 'filesystem', 'deleteFile', 60000, path
    
      delete @lastEditTimes[documentClassId][document._id]
