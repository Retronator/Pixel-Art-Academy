LOI = LandsOfIllusions
Behavior = LOI.Character.Behavior

if Meteor.isServer
  Document.startup =>
    Behavior.Perks.DeadEndJob.createSelf()
