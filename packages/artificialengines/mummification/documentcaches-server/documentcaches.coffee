AM = Artificial.Mummification

class AM.DocumentCaches
  @_caches = []
  
  @add: (filename, getter) ->
    @_caches.push {filename, getter}
    
  @export: (archive) ->
    console.log "Starting document caches export ..."

    for cache in @_caches
      exportingDocuments = cache.getter()
      
      # Place directory in the archive.
      archive.append EJSON.stringify(exportingDocuments), name: cache.filename

    # Complete exporting.
    archive.finalize()

    console.log "Document caches export done!"
