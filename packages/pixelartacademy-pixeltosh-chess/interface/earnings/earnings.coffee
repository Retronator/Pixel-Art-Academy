AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Earnings extends FM.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Earnings'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    programId: PAA.Pixeltosh.Programs.Chess.id()
    left: 0
    top: 0
    right: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    
    @pendingRewards = Chess.pendingRewards()
    
  onRendered: ->
    super arguments...
    
    await _.waitForSeconds 1
    
    targetOffset = $('.player-status .currency-area .currency').offset()
    scale = @os.display.scale()
    
    # Determine the style of the animation.
    slowCPUEmulation = LOI.settings.graphics.slowCPUEmulation.value()
    duration = if slowCPUEmulation then 400 else 300
    easing = if slowCPUEmulation then 'linear' else 'easeOutQuad'
    delayPerReward = 100
    
    $rewards = @$('.rewards')
    
    rewardPromises = for reward, rewardIndex in _.reverse $rewards
      $value = $(reward).find('.value')
      sourceOffset = $value.offset()

      offset =
        left: (targetOffset.left - sourceOffset.left) / scale
        top: (targetOffset.top - sourceOffset.top) / scale
        
      new Promise (resolve) =>
        do (offset, $value) =>
          $value.velocity
            tween: 1
          ,
            duration: duration
            easing: easing
            delay: delayPerReward * rewardIndex
            progress: (elements, complete, remaining, start, tweenValue) =>
              if slowCPUEmulation
                currentFrameTime = Date.now()
                return if lastFrameTime? and currentFrameTime - lastFrameTime < frameDuration
                lastFrameTime = currentFrameTime
              
              $value.css
                left: "#{Math.round offset.left * tweenValue}rem"
                top: "#{Math.round offset.top * tweenValue}rem"
                
            complete: =>
              $value.css 'visibility', 'hidden'
              
              pendingReward = @pendingRewards.pop()
              Chess.pendingRewards @pendingRewards
              reward = @chess.rewardsManager()?.getReward pendingReward.id
              Chess.currency Chess.currency() + reward.value pendingReward.data
              
              Tracker.afterFlush => resolve()
            
    await Promise.all rewardPromises
    
    @chess.interfaceManager().closeEarnings()
  
  reward: ->
    pendingReward = @currentData()
    @chess.rewardsManager()?.getReward pendingReward.id
