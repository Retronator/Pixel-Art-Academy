LOI = LandsOfIllusions
PADB = PixelArtDatabase

class LOI.Character extends LOI.Character
  # artist: real life artist this character represents
  #   _id
  #   displayName
  @Meta
    name: 'LandsOfIllusionsCharacter'
    replaceParent: true
    fields: =>
      artist: @ReferenceField PADB.Artist, ['displayName'] , true, 'characters', ['name']
