AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.DescriptionListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    currentPhysicalThings = LOI.adventure.currentPhysicalThings()

    for thing in currentPhysicalThings
      do (thing) =>
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.WhatIs, Vocabulary.Keys.Verbs.WhoIs], thing.avatar]
          action: =>
            LOI.adventure.showDescription thing

            # If we have a character and an object for the thing, the character should face the thing.
            return unless character = LOI.character()
            return unless object = LOI.adventure.world.sceneManager().getObjectForThing thing

            objectCenter = object.boundingBox().getCenter()

            renderObject = character.avatar.getRenderObject()
            renderObject.facePosition objectCenter
