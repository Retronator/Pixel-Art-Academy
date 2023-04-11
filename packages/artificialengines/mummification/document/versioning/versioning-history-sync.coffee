AE = Artificial.Everywhere
AM = Artificial.Mummification

AM.Document.Versioning.syncHistory = (document, latestHistory, requestFullDocumentCallback) ->
  # We only handle changes that are ahead of the document. If they are behind, we assume the
  # source of the changes will get the latest history from us and reset their changes.
  return if latestHistory.lastEditTime < document.lastEditTime
  
  # We must make sure our document state reflects the on from the sender.
  # See how many actions (up to history position) are matching.
  matchingActionsCount = 0

  console.log "Syncing history", document.historyPosition, latestHistory.historyPosition, document if Artificial.debug
  
  for historyPosition in [latestHistory.historyStart...latestHistory.historyPosition]
    documentActionIndex = historyPosition - document.historyStart
    latestHistoryActionIndex = historyPosition - latestHistory.historyStart
    
    break unless documentAction = document.history[documentActionIndex]
    latestHistoryAction = latestHistory.history[latestHistoryActionIndex]

    # For efficiency we only compare hash codes.
    if documentAction.hashCode is latestHistoryAction.hashCode
      matchingActionsCount++
      
    else
      break
      
  # If history position matches and all previous actions match, there's nothing to do.
  return if latestHistory.historyPosition is document.historyPosition and matchingActionsCount is latestHistory.historyPosition - latestHistory.historyStart
  
  # If we don't have any matching actions, we can't roll back far enough to get to a synced state, so we have to request
  # the full document from the sender. The exception is when we're actually trying to roll back to the start of history.
  unless matchingActionsCount or latestHistory.historyPosition is 0
    requestFullDocumentCallback()
    return
  
  # If we have a partial action in progress, we need to roll back its effects.
  AM.Document.Versioning.executeOperations document, document.partialAction.backward if document.partialAction
  
  # Roll back all non-matching document actions.
  lastMatchingHistoryPosition = latestHistory.historyStart + matchingActionsCount
  rollbackPosition = Math.min document.historyPosition, lastMatchingHistoryPosition
  
  for historyPosition in [document.historyPosition...rollbackPosition]
    documentActionIndex = historyPosition - document.historyStart - 1
    documentAction = document.history[documentActionIndex]
    
    AM.Document.Versioning.executeOperations document, documentAction.backward

  # Apply all non-matching latest actions.
  for historyPosition in [rollbackPosition...latestHistory.historyPosition]
    latestHistoryActionIndex = historyPosition - latestHistory.historyStart
    latestHistoryAction = latestHistory.history[latestHistoryActionIndex]

    AM.Document.Versioning.executeOperations document, latestHistoryAction.forward

  # If we have a partial action in progress, we need to apply its effects again.
  AM.Document.Versioning.executeOperations document, document.partialAction.forward if document.partialAction

  # Sync history fields.
  document.lastEditTime = latestHistory.lastEditTime
  document.historyPosition = latestHistory.historyPosition

  lastMatchingDocumentActionIndex = lastMatchingHistoryPosition - document.historyStart - 1
  lastMatchingLatestHistoryActionIndex = lastMatchingHistoryPosition - latestHistory.historyStart - 1
  
  newActions = latestHistory.history[lastMatchingLatestHistoryActionIndex + 1..]
  
  document.history.splice lastMatchingDocumentActionIndex + 1, document.history.length, newActions...
