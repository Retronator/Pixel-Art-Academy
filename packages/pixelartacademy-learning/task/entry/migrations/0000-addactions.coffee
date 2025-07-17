LOI = LandsOfIllusions
PAA = PixelArtAcademy

class Migration extends Document.MajorMigration
  name: "Add actions."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    actionsCollection = if Meteor.isClient then LOI.Memory.Action.documents else new DirectCollection 'LandsOfIllusions.Memory.Actions'
    charactersCollection =  if Meteor.isClient then LOI.Character.documents else new DirectCollection 'LandsOfIllusions.Characters'

    collection.findEach
      _schema: currentSchema
      action: $exists: false
    ,
      (document) =>
        # Add an Action document for this entry.
        character = charactersCollection.findOne _id: document.character._id

        action =
          _id: Random.id()
          _schema: '5.0.0'
          type: 'PixelArtAcademy.Learning.Task.Entry.Action'
          time: document.time
          timelineId: 'Present'
          locationId: 'Retronator.HQ.Cafe'
          character:
            _id: document.character._id
            avatar:
              fullName: character.avatar?.fullName
              color: character.avatar?.color
          content:
            taskEntry: [
              _id: document._id
              taskId: document.taskId
            ]

        actionsCollection.insert action

        # Add the action field.
        count += collection.update
          _id: document._id
        ,
          $set:
            action:
              _id: action._id

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      action: $exists: true
    ,
      (document) =>
        # Delete the Action document.
        actionsCollection.remove document.action._id

        # Remove the action field.
        count += collection.update
          _id: document._id
        ,
          $unset:
            action: true
            
    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PAA.Learning.Task.Entry.addMigration new Migration()
