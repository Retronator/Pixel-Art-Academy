LOI = LandsOfIllusions

LOI.Character.Part.Template.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Character.Part.Template.documents.find id

LOI.Character.Part.Template.forType.publish (type) ->
  check type, String

  LOI.Character.Part.Template._forTypes [type], @userId

LOI.Character.Part.Template.forTypes.publish (types) ->
  check types, [String]

  LOI.Character.Part.Template._forTypes types, @userId

# We separate the method so that we can get just the cursor from other server methods.
LOI.Character.Part.Template._forTypes = (types, userId) ->
  # We do not return current user's templates since we assume those will come from the current user subscription.
  # We do this separation because otherwise the same document might be sent from two subscriptions, making it
  # unpredictable if the author field will be present (it needs to be for user's templates).
  LOI.Character.Part.Template.documents.find
    type:
      $in: types
    'author._id':
      $ne: userId
  ,
    fields:
      author: 0

LOI.Character.Part.Template.forCurrentUser.publish ->
  LOI.Character.Part.Template._forUserId @userId

LOI.Character.Part.Template._forUserId = (userId) ->
  LOI.Character.Part.Template.documents.find
    'author._id': userId
