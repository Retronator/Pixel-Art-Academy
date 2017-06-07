LOI = LandsOfIllusions

LOI.Character.Part.Template.updateData.method (templateId, address, value) ->
  check id, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.avatarEditor()

  template = LOI.Character.Part.Template.documents.findOne templateId

  # User must be the author of this template.
  user = Retronator.requireUser()
  throw new AE.UnauthorizedException "You must be the author of the template to change it." unless template.author._id is user._id

  LOI.Character.documents.update templateId,
    $set:
      "data.#{address}": value
