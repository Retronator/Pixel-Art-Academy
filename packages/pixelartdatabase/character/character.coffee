LOI = LandsOfIllusions
PADB = PixelArtDatabase

class LOI.Character extends LOI.Character
  # artist: real life artist this character represents
  #   _id
  #   publicName
  @Meta
    name: 'LandsOfIllusions.Character'
    replaceParent: true
    fields: =>
      artist: Document.ReferenceField PADB.Artist, ['publicName'] , true, 'characters', ['name']
