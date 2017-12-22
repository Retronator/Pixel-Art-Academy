AE = Artificial.Everywhere
Blog = Retronator.Blog

# Get all the posts needed to display a blog issue.
Blog.Post.getIssueData.method (urlState) ->
  check urlState,
    page: Match.OptionalOrNull Match.PositiveInteger
    tag: Match.OptionalOrNull String
    postId: Match.OptionalOrNull Number
    postsPerPage: Match.OptionalOrNull Match.PositiveInteger

  query = {}
  queryOptions =
    fields:
      data: 0

  if urlState.postId
    query = 'tumblr.id': urlState.postId
    pagesCount = 1

  else
    query = urlTags: urlState.tag if urlState.tag
    postsPerPage = urlState.postsPerPage or 15

    _.extend queryOptions,
      sort:
        time: -1
      limit: postsPerPage
      skip: (urlState.page - 1) * postsPerPage

    pagesCount =  Math.ceil Blog.Post.documents.find(query).count() / postsPerPage

  posts: Blog.Post.documents.find(query, queryOptions).fetch()
  pagesCount: pagesCount
