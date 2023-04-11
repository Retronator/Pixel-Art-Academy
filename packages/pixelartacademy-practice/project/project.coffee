AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Project'
  # profileId: profile that created the project
  # lastEditTime: the time the document was last edited
  # startTime: when the project was started
  # endTime: when the project was ended
  # type: project identifier that matches the project's thing ID
  # assets: array of assets that are part of this project
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   BITMAP
  #   bitmapId: reference to a bitmap
  @Meta
    name: @id()
    fields: =>
      assets: [
        bitmap: Document.ReferenceField LOI.Assets.Bitmap
      ]
      
  @enablePersistence()

  # Subscriptions

  @forId: @subscription 'forId'
  @forCharacterId: @subscription 'forCharacterId'
