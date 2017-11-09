RS = Retronator.Store

class TopRecentTransactions
  @documents: new Meteor.Collection 'TopRecentTransactions'

  constructor: (@publish, @count) ->
    @_sortedTransactions = []

  added: (document) ->
    # Add the new document and see at what index it got placed.
    sortedDocument = @_addAndSort document

    # If the index is in the top @count, add the document to the collection.
    @_addToPublished sortedDocument if sortedDocument.index < @count

  changed: (document, oldDocument) ->
    # Remove the old document and see from which index it got removed.
    oldSortedDocument = @_remove oldDocument
    oldIndex = oldSortedDocument.index

    # Add the new document and see at what index it got placed.
    sortedDocument = @_addAndSort document
    newIndex = sortedDocument.index

    # Now we have four options.
    if newIndex < @count and oldIndex < @count
      # Document was in top @count and remained in top @count in which case we just report the change.
      @_changePublished sortedDocument

    else if newIndex < @count
      # Document moved into the top @count because of the change so we add it.
      @_addToPublished sortedDocument

    else if oldIndex < @count
      # Document fell out of top @count because of the change so we remove it.
      @_removeFromPublished sortedDocument

    else
      # The object wasn't in the top @count and now also isn't so we have nothing to do.

  removed: (document) ->
    # Remove the document and see from which index it got removed.
    sortedDocument = @_remove document

    # If the index is in the top @count, remove the document from the collection.
    @_removeFromPublished sortedDocument if sortedDocument.index < @count

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

    # Also remove the 11th document, since it was pushed out of the top @count.
    eleventhSortedDocument = @_sortedTransactions[@count]
    @publish.removed 'TopRecentTransactions', eleventhSortedDocument._id if eleventhSortedDocument

  _changePublished: (sortedDocument) ->
    @publish.changed 'TopRecentTransactions', sortedDocument._id, sortedDocument.publicDocument

  _removeFromPublished: (sortedDocument) ->
    @publish.removed 'TopRecentTransactions', sortedDocument._id

    # Also add the @countth document, since it was pushed into the top @count.
    tenthSortedDocument = @_sortedTransactions[@count - 1]
    @publish.added 'TopRecentTransactions', tenthSortedDocument._id, tenthSortedDocument.publicDocument if tenthSortedDocument

  @summarizeDocument: (document) ->
    # Create a summary document that only has a supporter name, amount and message. It's OK for fields to be set to
    # undefined otherwise since the field should be removed when calling changed on the publish handle.
    supporterName = if document.user?._id then document.user.supporterName else document.supporterName

    # We want to show people with name and/or message first.
    priority = (if supporterName then 1 else 0) + (if document.tip?.message then 1 else 0)

    amount: document.totalValue
    time: document.time
    message: document.tip?.message
    name: supporterName
    priority: priority

  _updateSortedIndices: ->
    for i in [0...@_sortedTransactions.length]
      @_sortedTransactions[i].index = i

Meteor.publish RS.Transaction.topRecent, (count = 10) ->
  # We are returning the list of top recent transactions with supporters' names, amounts and messages. We do this by
  # looking at last 50 transactions and only returning the top ones sorted by value. We return these using a special
  # collection TopRecentTransactions that only holds these results.
  topRecentTransactions = new TopRecentTransactions @, count

  # Listen to last transactions (4 times as much as we'll send to the client) that have some value.
  RS.Transaction.documents.find(
    totalValue:
      $gt: 0
  ,
    sort:
      time: -1
    limit: count * 4
  ).observe
    added: (document) => topRecentTransactions.added document
    changed: (document, oldDocument) => topRecentTransactions.changed document, oldDocument
    removed: (document) => topRecentTransactions.removed document

  @ready()

transactionMessages = new Meteor.Collection 'TransactionMessages'

summarizeMessage = (document) ->
  summary = TopRecentTransactions.summarizeDocument document
  _.omit summary, 'amount'

Meteor.publish RS.Transaction.messages, (count) ->
  check count, Match.PositiveInteger

  RS.Transaction.documents.find(
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
