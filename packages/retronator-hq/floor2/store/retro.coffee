LOI = LandsOfIllusions
HQ = Retronator.HQ
Blog = Retronator.Blog

class HQ.Store.Retro extends HQ.Actors.Retro
  constructor: ->
    super arguments...

    Blog.Post.all.subscribe 1

    # Dynamically create the 5 things on the table.
    @newestTableItem = new ComputedField =>
      newestPost = Blog.Post.documents.findOne {},
        sort:
          fime: -1

      return unless newestPost

      HQ.Store.Table.Item.createItem
        post: newestPost
        retro: @
        visible: false

  descriptiveName: ->
    justName = "Matej '![Retro](talk to Retro)' Jan."
    return justName unless newestPost = @newestTableItem()?.post

    switch newestPost.type
      when Blog.Post.Types.Photo
        if newestPost.photos.length is 1
          action = "admiring a ![photo](look at photo)"

        else
          action = "browsing through some ![photos](look at photos)"

      when Blog.Post.Types.Video
        action = "watching a ![video](view video)"

      when Blog.Post.Types.Article
        action = "reading an ![article](read article)"

      when Blog.Post.Types.Link
        action = "surfing a ![webpage](look at webpage)"

      when Blog.Post.Types.Quote
        action = "reading a ![quote](read quote)"

      when Blog.Post.Types.Audio
        action = "listening to a ![cassette tape](listen to cassette tape)"

      when Blog.Post.Types.Conversation
        action = "having a ![conversation](listen to conversation)"

      when Blog.Post.Types.Answer
        action = "answering a ![question](see the answer)"

    "#{justName} He is #{action}."
