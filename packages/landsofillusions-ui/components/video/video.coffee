AM = Artificial.Mirage
LOI = LandsOfIllusions

# Plays a video automatically, pausing while the adventure menu is visible.
# Data accepts src, muted (defaults to true), loop, and an optional onEnded callback.
class LOI.Components.Video extends AM.Component
  @register 'LandsOfIllusions.Components.Video'

  onRendered: ->
    super arguments...

    @_video = @$('.video')[0]
    @_$progressBar = @$('.progress-bar')
    
    @_video.ontimeupdate = => @_updateProgress()
    @_video.ondurationchange = => @_updateProgress()
    @_video.onemptied = => @_updateProgress()
    @_video.onpause = => @_updateProgress()
    @_video.onplaying = => @_previousProgressUpdateTime = performance.now()
    @_video.onended = =>
      @_$progressBar.velocity('stop', true).css(width: '100%')
      @data().onEnded?()

    # Match video volume to audio settings.
    @autorun (computation) =>
      audioEnabled = LOI.adventure?.audioManager?.enabled()
      @_video.muted = if @data().muted then true else not audioEnabled
      @_video.volume = LOI.settings?.audio.mainVolume.value()

    # Play and pause the video.
    @autorun (computation) =>
      data = @data()
      menuVisible = LOI.adventure?.menu?.visible()

      # Loop if requested.
      @_video.loop = data.loop ? false

      # Assign the source before playing, and restart only when the source changes.
      if data.src isnt @_source
        @_source = data.src
        @_previousProgressUpdateTime = null
        @_$progressBar.velocity('stop', true).css(width: '0')
        @_video.src = data.src

      if menuVisible
        @_video.pause()

      else unless @_video.ended
        # Pausing or removing a video while play is pending rejects the play promise.
        @_video.play()?.catch (error) =>
          return if error.name is 'AbortError'
          
          console.warn "Could not play video.", error

  onDestroyed: ->
    super arguments...

    if @_video
      @_video.onended = null
      @_video.ontimeupdate = null
      @_video.ondurationchange = null
      @_video.onemptied = null
      @_video.onpause = null
      @_video.onplaying = null
      @_video.pause()
      @_video.removeAttribute 'src'
      @_video.load()
    
    @_$progressBar?.velocity('stop', true)
  
  _updateProgress: ->
    # Calculate progress if data is available.
    progress = 0

    if Number.isFinite(@_video.duration) and @_video.duration
      progress = @_video.currentTime / @_video.duration

    # Animate the progress bar from the previous value.
    updateTime = performance.now()
    duration = if @_previousProgressUpdateTime? then updateTime - @_previousProgressUpdateTime else 0
    @_previousProgressUpdateTime = updateTime

    # Reset when video is not playing.
    if @_video.paused or @_video.ended
      duration = 0
      @_previousProgressUpdateTime = null

    # Set the progress bar width.
    width = "#{progress * 100}%"
    @_$progressBar.velocity('stop', true)

    if duration
      @_$progressBar.velocity {width}, {duration, easing: 'linear'}

    else
      @_$progressBar.css {width}
