AB = Artificial.Babel
LOI = LandsOfIllusions

LOI.Character.Part.Template.insert.method (data, options) ->
  check data, Match.ObjectIncluding fields: Object
  check options, Match.ObjectIncluding type: String

  LOI.Authorize.avatarEditor()

  userId = Meteor.userId()

  LOI.Character.Part.Template.documents.insert
    author: _id: userId
    name: _id: AB.Translation.documents.insert ownerId: userId
    description: _id: AB.Translation.documents.insert ownerId: userId
    type: options.type
    data: data

LOI.Character.Part.Template.updateData.method (templateId, address, value) ->
  check templateId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.avatarEditor()

  template = LOI.Character.Part.Template.documents.findOne templateId

  # User must be the author of this template.
  user = Retronator.requireUser()
  throw new AE.UnauthorizedException "You must be the author of the template to change it." unless template.author._id is user._id

  if value?
    update =
      $set:
        "data.#{address}": value
  else
    update =
      $unset:
        "data.#{address}": true

  LOI.Character.Part.Template.documents.update templateId, update
