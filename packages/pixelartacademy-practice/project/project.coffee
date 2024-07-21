AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Project'
  # profileId: profile that created the project
  # name: text identifier for the project including the path, used for public projects
  # lastEditTime: the time the document was last edited
  # startTime: when the project was started
  # endTime: when the project was ended
  # type: project identifier that matches the project's thing ID
  # assets: array of assets that are part of this project
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   BITMAP
  #   bitmapId: ID of the bitmap representing this asset
  @Meta
    name: @id()
    
  @enablePersistence()
  @enableDatabaseContent()

  # Subscriptions

  @all: @subscription 'all'
  @forId: @subscription 'forId'
  @forCharacterId: @subscription 'forCharacterId'
  @assetsForProjectId: @subscription 'assetsForProjectId'
