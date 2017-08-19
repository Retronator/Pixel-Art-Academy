LOI = LandsOfIllusions
Behavior = LOI.Character.Behavior

if Meteor.isServer
  Document.startup =>
    Behavior.Activity.create
      key: Behavior.Activities.Keys.Sleep
      name: "Sleep"

    Behavior.Activity.create
      key: Behavior.Activities.Keys.Job
      name: "Job"

    Behavior.Activity.create
      key: Behavior.Activities.Keys.School
      name: "School"

    Behavior.Activity.create
      key: Behavior.Activities.Keys.Drawing
      name: "Drawing"
