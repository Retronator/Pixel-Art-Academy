RA = Retronator.Accounts
RS = Retronator.Store

RS.Item.Key.retrieve.method (catalogKey) ->
  check catalogKey, String
  
  console.log "retrieving key", catalogKey
  
  catalogKey
