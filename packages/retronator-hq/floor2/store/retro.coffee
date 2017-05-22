LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
Blog = Retronator.Blog

class HQ.Store.Retro extends HQ.Actors.Retro
  constructor: ->
    super

    Blog.Post.all.subscribe 1

    # Dynamically create the 5 things on the table.
    @newestTableItem = new ComputedField =>
      newestPost = Blog.Post.documents.findOne {},
        sort:
          fime: -1

      return unless newestPost

      HQ.Store.Table.Item.createItem newestPost, visible: false

  descriptiveName: ->
    return unless newestPost = @newestTableItem()?.post

    switch newestPost.type
      when Blog.Post.Types.Photo
        if newestPost.photos.length is 1
          action = "admiring a ![photo](look at photo)"

        else
          action = "browsing through some ![photos](look at photos)"

    "Matej '![Retro](talk to Retro)' Jan. He is #{action}."
