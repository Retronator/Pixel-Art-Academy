AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Project'
  # startTime: when the project was started
  # endTime: when the project was ended
  # type: project identifier that matches the project's thing ID
  # characters: array of characters who work on this project
  #   _id
  #   avatar
  #     fullName
  # assets: array of assets that are part of this project
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   SPRITE
  #   sprite: reference to a sprite
  #     _id
  @Meta
    name: @id()
    fields: =>
      characters: [Document.ReferenceField LOI.Character, ['avatar.fullName']]
      assets: [
        sprite: Document.ReferenceField LOI.Assets.Sprite
      ]

  # Subscriptions

  @forId: @subscription 'forId'
  @forCharacterId: @subscription 'forCharacterId'
