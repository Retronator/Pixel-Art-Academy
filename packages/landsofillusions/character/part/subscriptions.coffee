LOI = LandsOfIllusions

LOI.Character.Part.Template.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Character.Part.Template.documents.find id

LOI.Character.Part.Template.forType.publish (type, options) ->
  check type, String

  LOI.Character.Part.Template._forTypes [type], options, @userId

LOI.Character.Part.Template.forTypes.publish (types, options) ->
  check types, [String]

  LOI.Character.Part.Template._forTypes types, options, @userId

# We separate the method so that we can get just the cursor from other server methods.
LOI.Character.Part.Template._forTypes = (types, options = {}, userId) ->
  check options,
    skipCurrentUsersTemplates: Match.Optional Boolean

  query =
    type:
      $in: types

  # If the user is subscribed to templates for current user, we shouldn't return those, because otherwise the same
  # document might be sent from two subscriptions, making it unpredictable if the author field will be present (it
  # needs to be for user's templates).
  if options.skipCurrentUsersTemplates
    query['author._id'] =
      $ne: userId

  LOI.Character.Part.Template.documents.find query,
    fields:
      author: 0

LOI.Character.Part.Template.forCurrentUser.publish ->
  LOI.Character.Part.Template.documents.find
    'author._id': @userId
