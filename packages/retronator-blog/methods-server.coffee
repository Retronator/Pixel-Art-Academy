AB = Artificial.Base
AT = Artificial.Telepathy
Blog = Retronator.Blog

blogInfo =
  lastUpdated: 0
  data: null

Blog.getData.method ->
  # Returned cached information if it's not older than one hour.
  return blogInfo.data if Date.now() - blogInfo.lastUpdated < 1000 * 60 * 60

  # Grab new information from Tumblr.
  info = AT.Tumblr.userInfo()
  followers = AT.Tumblr.blogFollowers 'retronator.tumblr.com'

  blogInfo =
    lastUpdated: Date.now()
    data:
      blogInfo:
        likes: info.user.likes
        following: info.user.following
        followers: followers.total_users
      supporterMessages: Retronator.Store.Transaction.getMessages()
      supportersWithNames: Retronator.Accounts.User.getSupportersWithNames()

  # Return fresh information.
  blogInfo.data

# Create an HTTP endpoint for retronator.com.
AB.addPickerRoute '/daily/data.json', (routeParameters, request, response, next) =>
  response.writeHead 200,
    'Content-type': 'application/json'
    'Access-Control-Allow-Origin': 'http://www.retronator.com'

    response.write JSON.stringify Blog.getData()

  next()
