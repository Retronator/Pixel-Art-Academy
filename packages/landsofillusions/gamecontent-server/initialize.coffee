LOI = LandsOfIllusions

Document.prepare ->
  return if Meteor.settings.startEmpty

  exportedDocuments = JSON.parse Assets.getText 'gamecontent-server/gamecontent.json'

  LOI.GameContent.import exportedDocuments
