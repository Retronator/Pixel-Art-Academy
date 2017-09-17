LOI = LandsOfIllusions

LOI.Character.Part.Template.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Character.Part.Template.documents.find id

LOI.Character.Part.Template.forType.publish (type) ->
  check type, String

  # We do not return current user's templates since we assume those will come from the current user subscription.
  # We do this separation because otherwise the same document might be sent from two subscriptions, making it
  # unpredictable if the author field will be present (it needs to be for user's templates).
  LOI.Character.Part.Template.documents.find
    type: type
    'author._id':
      $ne: @userId
  ,
    fields:
      author: 0

LOI.Character.Part.Template.forCurrentUser.publish ->
  LOI.Character.Part.Template.documents.find
    'author._id': @userId
