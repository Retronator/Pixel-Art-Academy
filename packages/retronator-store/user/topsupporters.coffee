RA = Retronator.Accounts

topSupporters = new Meteor.Collection 'TopSupporters'

summarizeUser = (user) ->
  amount: user.supportAmount
  time: user.createdAt
  name: user.supporterName

Meteor.publish RA.User.topSupporters, ->
  # We are returning the list of top 10 users by their support amount. We return
  # these using a special collection TopSupporters that only holds these results.
  RA.User.documents.find(
    supportAmount:
      $gt: 0
  ,
    sort:
      [
        ['supportAmount', 'desc']
        ['createdAt', 'desc']
      ]
    limit: 10
  ).observe
    added: (user) => @added 'TopSupporters', user._id, summarizeUser user
    changed: (user) => @changed 'TopSupporters', user._id, summarizeUser user
    removed: (user) => @removed 'TopSupporters', user._id, summarizeUser user

  @ready()
