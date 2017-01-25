AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016 extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Top2016'
  
  constructor: ->
    super
    
    @backgrounds = [
      url: 'http://pbs.twimg.com/media/Ci9SIL8UkAI1tI5.png'
      position: ['0%', '50%']
      author: 'skittlefuck'
    ,
      url: 'http://pbs.twimg.com/media/CxLBA7PVEAELURt.png'
      position: ['100%', '0%']
      author: 'jtangc'
    ,
      url: 'http://pbs.twimg.com/tweet_video_thumb/CX6sqnbW8AQ9ECT.png'
      position: ['30%', '40%']
      author: 'Weilard'
    ,
      url: 'http://pbs.twimg.com/media/Cx-y8-sUAAABbl1.png'
      position: ['100%', '0%']
      author: 'skittlefuck'
    ,
      url: 'http://pbs.twimg.com/media/CjW6CwjUYAIQVo8.png'
      position: ['0%', '100%']
      author: 'watawatabou'
    ,
      url: 'http://pbs.twimg.com/media/CvO23_LVUAY5ZwK.png'
      position: ['50%', '0%']
      author: 'ricardojuchem'
    ,
      url: 'http://pbs.twimg.com/media/CzXz-x3UAAEWb4e.jpg'
      position: ['0%', '70%']
      author: 'Helgram'
    ,
      url: 'http://pbs.twimg.com/tweet_video_thumb/CnM1_1uWEAADG9K.jpg'
      position: ['80%', '0%']
      author: 'Weilard'
    ,
      url: 'http://pbs.twimg.com/media/CoK5EvbUkAAOfUh.jpg'
      position: ['100%', '0%']
      author: 'VeryJerryPie'
    ,
      url: 'http://pbs.twimg.com/media/Cecn8oIW8AAK6uS.jpg'
      position: ['0%', '100%']
      author: 'orangemagik'
    ]

    # Shuffle the backgrounds, but leave the starting one fixed.
    @backgrounds = _.flatten [@backgrounds[0], _.shuffle @backgrounds[1..]]

    @currentBackgroundIndex = new ReactiveField null

  onRendered: ->
    @_changeBackgroundInterval = Meteor.setInterval =>
      newIndex = (@currentBackgroundIndex() + 1) % @backgrounds.length

      # Temporarily remove the background so that animations get triggered.
      @currentBackgroundIndex null

      Tracker.afterFlush =>
        @currentBackgroundIndex newIndex
    ,
      10000

    @currentBackgroundIndex 0

  onDestroyed: ->
    Meteor.clearInterval @_changeBackgroundInterval

  background: ->
    index = @currentBackgroundIndex()
    return unless index?

    @backgrounds[index]

  isFullscreen: ->
    AM.Window.isFullscreen()

  insertDOMElement: (parent, node, before) ->
    super
    $node = $(node)

    return unless $node.hasClass 'background'

    # Do a background transition.
    position = @backgrounds[@currentBackgroundIndex()].position

    $node.css(backgroundPositionY: position[0])

    Meteor.setTimeout =>
      $node.addClass('transition').css(backgroundPositionY: position[1])
    ,
      500

  removeDOMElement: (parent, node) ->
    $node = $(node)

    unless $node.hasClass 'background'
      super
      return

    $node.addClass('old').velocity
      opacity: [0, 1]
    ,
      duration: 1000
      complete: => $node.remove()

  events: ->
    super.concat
      'click .fullscreen': @onClickFullscreen

  onClickFullscreen: (event) ->
    AM.Window.enterFullscreen()
