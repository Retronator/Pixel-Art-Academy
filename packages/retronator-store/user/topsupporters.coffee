RA = Retronator.Accounts

topSupporters = new Meteor.Collection 'TopSupporters'

summarizeUser = (user) ->
  # Calculate user's supporter rank. It is the number of other users with higher support amount plus one.
  higherRankingUsersCount = RA.User.documents.find(
    _id:
      $ne: user._id
    supportAmount:
      $gt: user.supportAmount
  ).count()

  supporterRank = higherRankingUsersCount + 1
  
  # We want to show people with name and/or message first.
  priority = (if user.supporterName then 1 else 0) + (if user.profile?supporterMessage then 1 else 0)

  amount: user.supportAmount
  rank: supporterRank
  time: user.createdAt
  name: user.supporterName
  message: user.profile?.supporterMessage
  priority: priority

Meteor.publish RA.User.topSupporters, (count) ->
  # We are returning the list of top users by their support amount. We return
  # these using a special collection TopSupporters that only holds these results.
  RA.User.documents.find(
    supportAmount:
      $gt: 0
  ,
    sort:
      [
        ['supportAmount', 'desc']
        ['supporterName', 'desc']
        ['profile.supporterMessage', 'desc']
        ['createdAt', 'desc']
      ]
    limit: count
  ).observe
    added: (user) => @added 'TopSupporters', user._id, summarizeUser user
    changed: (user) => @changed 'TopSupporters', user._id, summarizeUser user
    removed: (user) => @removed 'TopSupporters', user._id, summarizeUser user

  @ready()

Meteor.publish RA.User.topSupportersCurrentUser, ->
  # We are returning the current users and adding their current rank. We return
  # these using a special collection TopSupporters that only holds these results.
  RA.User.documents.find(
    _id: @userId
  ).observe
    added: (user) => @added 'TopSupporters', user._id, summarizeUser user
    changed: (user) => @changed 'TopSupporters', user._id, summarizeUser user
    removed: (user) => @removed 'TopSupporters', user._id, summarizeUser user

  @ready()
