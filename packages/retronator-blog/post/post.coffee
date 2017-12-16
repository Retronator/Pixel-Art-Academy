AM = Artificial.Mummification
Blog = Retronator.Blog

class Blog.Post extends AM.Document
  @id: -> 'Retronator.Blog.Post'
  # type: Tumblr's post type
  # tags: array of tag strings categorizing the post
  # time: time when this post was posted
  # notesCount: number of notes this post received
  # source: the source of information or content in the post
  #   title
  #   url
  # data: raw data of the post
  @Meta
    name: @id()

  @Types:
    Text: 'text'
    Quote: 'quote'
    Link: 'link'
    Answer: 'answer'
    Video: 'video'
    Audio: 'audio'
    Photo: 'photo'
    Chat: 'chat'

  # Subscriptions

  @all: @subscription 'all'
  @forDateRange: @subscription 'forDateRange'
  @forId: @subscription 'forId'
  @forTumblrId: @subscription 'forTumblrId'

  # Methods
  @getIssueData: @method 'getIssueData'
