AB = Artificial.Babel
AT = Artificial.Telepathy

class Retronator.Blog extends Retronator.Blog
  @processPost: (postData, options = {}) ->
    # Check if we already have it.
    existing = @Post.documents.findOne
      'data.id': postData.id

    # Only update notes count unless the content has changed.
    if existing and postData.timestamp is existing.data.timestamp and postData.date is existing.data.date and not options.reprocess
      # See if the notes count even is bigger.
      if existing.notesCount isnt postData.note_count
        @Post.documents.update existing._id,
          $set:
            notesCount: postData.note_count

      return

    # Process (or reprocess) the post.
    post =
      type: postData.type
      tags: postData.tags
      urlTags: _.map postData.tags, _.kebabCase
      time: new Date postData.timestamp * 1000
      notesCount: postData.note_count
      data: postData
      tumblr:
        id: postData.id
        slug: postData.slug
        url: postData.post_url

    if postData.source_url
      post.source =
        url: postData.source_url
        title: postData.source_title

    if postData.reblogged_root_id
      post.reblog =
        from:
          url: postData.reblogged_from_url
          name: postData.reblogged_from_name
          title: postData.reblogged_from_title
        root:
          url: postData.reblogged_root_url
          name: postData.reblogged_root_name
          title: postData.reblogged_root_title

    switch post.type
      when @Post.Types.Text
        post.title = postData.title
        post.text = postData.body

      when @Post.Types.Photo
        post.photos = postData.photos
        post.text = postData.caption
        post.layout = postData.photoset_layout if postData.photoset_layout

      when @Post.Types.Quote
        post.quote =
          text: postData.text
          source: postData.source

      when @Post.Types.Link
        post.photos = postData.photos
        post.text = postData.description
        post.link =
          title: postData.title
          url: postData.url
          author: postData.body
          excerpt: postData.excerpt
          publisher: postData.publisher

      when @Post.Types.Chat
        post.title = postData.title
        post.dialogue = postData.dialogue

      when @Post.Types.Audio
        post.text = postData.caption
        post.audio =
          player: postData.player
          plays: postData.plays
          albumArt: postData.album_art
          info:
            artist: postData.artist
            album: postData.album
            track_name: postData.track_name
            track_number: postData.track_number
            year: postData.year

      when @Post.Types.Video
        post.text = postData.caption
        post.video =
          player: postData.player
          type: postData.video_type
          thumbnail:
            url: postData.thumbnail_url
            width: postData.thumbnail_width
            height: postData.thumbnail_height

        post.video.url = postData.video_url if postData.video_url

      when @Post.Types.Answer
        post.question =
          askingName: postData.asking_name
          askingUrl: postData.asking_url
          question: postData.question
        post.text = postData.answer

    # Insert the processed post into the database (we do it with an if because
    # upsert on data.id somehow doesn't work correctly as it casts to double).
    if existing
      @Post.documents.update existing._id, post

    else
      @Post.documents.insert post
