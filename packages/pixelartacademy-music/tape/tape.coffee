AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music.Tape extends AM.Document
  @id: -> 'PixelArtAcademy.Music.Tape'
  # title: the name of this tape
  # artist: the author's name
  # slug: auto-generated URL identifier of the tape
  # sides: array with 1 or 2 sides
  #   title: optional title of this side of the tape
  #   tracks: an array of tracks on this side
  #     title
  #     duration
  #     url
  @Meta
    name: @id()
    fields: =>
      slug: Document.GeneratedField 'self', ['title', 'artist'], (tape) ->
        slug = _.kebabCase "#{tape.artist} #{tape.title}"
        [tape._id, slug]
      
  @enableDatabaseContent()
  
  # Subscriptions
  
  @all = @subscription 'all'
  @forId = @subscription 'forId'
