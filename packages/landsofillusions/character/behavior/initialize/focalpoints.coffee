LOI = LandsOfIllusions
Behavior = LOI.Character.Behavior

if Meteor.isServer
  Document.startup =>
    Behavior.FocalPoint.create
      key: Behavior.FocalPoints.Keys.Sleep
      name: "Sleep"

    Behavior.FocalPoint.create
      key: Behavior.FocalPoints.Keys.Job
      name: "Job"

    Behavior.FocalPoint.create
      key: Behavior.FocalPoints.Keys.School
      name: "School"

    Behavior.FocalPoint.create
      key: Behavior.FocalPoints.Keys.Drawing
      name: "Drawing"
