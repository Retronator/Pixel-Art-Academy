RS = Retronator.Store

class TopRecentTransactions
  @documents: new Meteor.Collection 'TopRecentTransactions'

  constructor: (@publish) ->
    @_sortedTransactions = []

  added: (document) ->
    # Add the new document and see at what index it got placed.
    sortedDocument = @_addAndSort document

    # If the index is in the top 10, add the document to the collection.
    @_addToPublished sortedDocument if sortedDocument.index < 10

  changed: (document, oldDocument) ->
    # Remove the old document and see from which index it got removed.
    oldSortedDocument = @_remove oldDocument
    oldIndex = oldSortedDocument.index

    # Add the new document and see at what index it got placed.
    sortedDocument = @_addAndSort document
    newIndex = sortedDocument.index

    # Now we have four options.
    if newIndex < 10 and oldIndex < 10
      # Document was in top 10 and remained in top 10 in which case we just report the change.
      @_changePublished sortedDocument

    else if newIndex < 10
      # Document moved into the top 10 because of the change so we add it.
      @_addToPublished sortedDocument

    else if oldIndex < 10
      # Document fell out of top 10 because of the change so we remove it.
      @_removeFromPublished sortedDocument

    else
      # The object wasn't in the top 10 and now also isn't so we have nothing to do.

  removed: (document) ->
    # Remove the document and see from which index it got removed.
    sortedDocument = @_remove document

    # If the index is in the top 10, remove the document from the collection.
    @_removeFromPublished sortedDocument if sortedDocument.index < 10

  _addAndSort: (document) ->
    # Create our internal document structure.
    sortedDocument =
      _id: document._id
      publicDocument: @constructor.summarizeDocument document

    # Insert the document and sort descending by value and time (top supporters first and latest first among them).
    @_sortedTransactions.push sortedDocument
    @_sortedTransactions.sort (a, b) ->
      # Sort by amount.
      amountDifference = b.publicDocument.amount - a.publicDocument.amount
      return amountDifference if amountDifference

      # Secondary sort by time.
      b.publicDocument.time - a.publicDocument.time

    # Recompute indices of documents.
    @_updateSortedIndices()

    # Return the created document.
    sortedDocument

  _remove: (document) ->
    # Find the index of the document.
    removeIndex = _.findIndex @_sortedTransactions, (sortedDocument) -> sortedDocument._id is document._id

    # Remove the document.
    sortedDocument = @_sortedTransactions[removeIndex]
    @_sortedTransactions.splice removeIndex, 1

    # Recompute indices of documents.
    @_updateSortedIndices()

    # Return the removed document.
    sortedDocument

  _addToPublished: (sortedDocument) ->
    @publish.added 'TopRecentTransactions', sortedDocument._id, sortedDocument.publicDocument

    # Also remove the 11th document, since it was pushed out of the top 10.
    eleventhSortedDocument = @_sortedTransactions[10]
    @publish.removed 'TopRecentTransactions', eleventhSortedDocument._id if eleventhSortedDocument

  _changePublished: (sortedDocument) ->
    @publish.changed 'TopRecentTransactions', sortedDocument._id, sortedDocument.publicDocument

  _removeFromPublished: (sortedDocument) ->
    @publish.removed 'TopRecentTransactions', sortedDocument._id

    # Also add the 10th document, since it was pushed into the top 10.
    tenthSortedDocument = @_sortedTransactions[9]
    @publish.added 'TopRecentTransactions', tenthSortedDocument._id, tenthSortedDocument.publicDocument if tenthSortedDocument

  @summarizeDocument: (document) ->
    # Create a summary document that only has a supporter name, amount and message. It's OK for fields to be set to
    # undefined otherwise since the field should be removed when calling changed on the publish handle.
    amount: document.totalValue
    time: document.time
    message: document.tip?.message
    name: if document.user?._id then document.user.supporterName else document.supporterName

  _updateSortedIndices: ->
    for i in [0...@_sortedTransactions.length]
      @_sortedTransactions[i].index = i

Meteor.publish RS.Transactions.Transaction.topRecent, ->
  # We are returning the list of top recent transactions with supporters' names, amounts and messages. We do this by
  # looking at last 50 transactions and only returning the top 10 sorted by value. We return these using a special
  # collection TopRecentTransactions that only holds these results.
  topRecentTransactions = new TopRecentTransactions @

  # Listen to last 50 transactions that have some value.
  RS.Transactions.Transaction.documents.find(
    totalValue:
      $gt: 0
  ,
    sort:
      time: -1
    limit: 50
  ).observe
    added: (document) => topRecentTransactions.added document
    changed: (document, oldDocument) => topRecentTransactions.changed document, oldDocument
    removed: (document) => topRecentTransactions.removed document

  @ready()

transactionMessages = new Meteor.Collection 'TransactionMessages'

summarizeMessage = (document) ->
  summary = TopRecentTransactions.summarizeDocument document
  _.omit summary, 'amount'

Meteor.publish RS.Transactions.Transaction.messages, (count) ->
  console.log "COUNT GOT", count
  check count, Match.PositiveInteger

  RS.Transactions.Transaction.documents.find(
    totalValue:
      $gt: 0
    'tip.message':
      $exists: true
  ,
    sort:
      time: -1
    limit: count
  ).observe
    added: (document) => @added 'TransactionMessages', document._id, summarizeMessage document
    changed: (document) => @changed 'TransactionMessages', document._id, summarizeMessage document
    removed: (document) => @removed 'TransactionMessages', document._id, summarizeMessage document

  @ready()
