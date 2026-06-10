PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.RewardsManager
  constructor: (@chess) ->
    @_rewardsById = {}
    @_rewards = for rewardClass in Chess.Reward.getClasses()
      @_rewardsById[rewardClass.id()] = new rewardClass @
  
  destroy: ->
    reward.destroy() for reward in @_rewards
  
  getReward: (rewardId) -> @_rewardsById[rewardId]
  
  onLessonCompleted: (completedCount) ->
    reward.onLessonCompleted completedCount for reward in @_rewards
