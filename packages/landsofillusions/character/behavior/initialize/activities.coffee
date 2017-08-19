LOI = LandsOfIllusions
Behavior = LOI.Character.Behavior

if Meteor.isServer
  Document.startup =>
    Behavior.Activity.create
      key: Behavior.Activity.Keys.Sleep
      name: "Sleep"

    Behavior.Activity.create
      key: Behavior.Activity.Keys.Job
      name: "Job"

    Behavior.Activity.create
      key: Behavior.Activity.Keys.School
      name: "School"

    Behavior.Activity.create
      key: Behavior.Activity.Keys.Drawing
      name: "Drawing"
