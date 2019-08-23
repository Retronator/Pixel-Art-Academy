AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.Character.Part.Template.insert.method (data, metaData) ->
  check data, Match.ObjectIncluding fields: Object
  check metaData, Match.ObjectIncluding type: String

  RA.authorizeAdmin()

  userId = Meteor.userId()

  LOI.Character.Part.Template.documents.insert
    author: _id: userId
    name: _id: AB.Translation.documents.insert ownerId: userId
    description: _id: AB.Translation.documents.insert ownerId: userId
    lastEditTime: new Date
    type: metaData.type
    data: data

LOI.Character.Part.Template.updateData.method (templateId, address, value) ->
  check templateId, Match.DocumentId
  check address, String
  check value, Match.Any

  RA.authorizeAdmin()

  template = LOI.Character.Part.Template.documents.findOne templateId
  LOI.Character.Part.Template._authorizeTemplateAction template

  if value?
    # Denormalize data into a template field when we have a specific version (otherwise we want live updating).
    LOI.Character.Part.Template.denormalizeTemplateField value.template if value.template?.version?
    
    update =
      $set:
        "data.#{address}": value
  else
    update =
      $unset:
        "data.#{address}": true

  # Mark change to the data.
  update.$set ?= {}
  update.$set.dataPublished = false

  update.$set.lastEditTime = new Date

  LOI.Character.Part.Template.documents.update templateId, update

LOI.Character.Part.Template.publish.method (templateId) ->
  check templateId, Match.DocumentId
  
  RA.authorizeAdmin()

  template = LOI.Character.Part.Template.documents.findOne templateId
  LOI.Character.Part.Template._authorizeTemplateAction template
  
  AM.Hierarchy.Template._publish LOI.Character.Part.Template, template,
    $set:
      lastEditTime: new Date

LOI.Character.Part.Template.revert.method (templateId) ->
  check templateId, Match.DocumentId
  
  RA.authorizeAdmin()

  template = LOI.Character.Part.Template.documents.findOne templateId
  LOI.Character.Part.Template._authorizeTemplateAction template

  AM.Hierarchy.Template._revert LOI.Character.Part.Template, template,
    $set:
      lastEditTime: new Date
