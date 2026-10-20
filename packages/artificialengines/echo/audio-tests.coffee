AEc = Artificial.Echo

Tinytest.add 'artificialengines - echo - audio nodes survive the launching view', (test) ->
  # Cached audio documents can create nodes inside the Finder event's view, whereas
  # documents arriving later create them outside it. Exercise both on repeated launches.
  for launchNumber in [1..6]
    nodesData = new ReactiveField [
      id: 'randomBuffer'
      type: AEc.Node.RandomBuffer.type()
      parameters: {}
    ]
    parentElement = document.createElement 'div'
    view = Blaze.render (new Blaze.View 'audio-launcher', -> null), parentElement
    audio = null

    try
      if launchNumber % 2
        audio = new AEc.Audio 'audio-restart-test', null, nodesData

      else
        audio = Blaze._withCurrentView view, ->
          new AEc.Audio 'audio-restart-test', null, nodesData

      randomBuffer = audio.getNode 'randomBuffer'
      Blaze.remove view

      # Simulate a sample becoming available after the launching view was removed.
      buffer = sample: launchNumber
      nodesData [
        id: 'randomBuffer'
        type: AEc.Node.RandomBuffer.type()
        parameters:
          buffer1: buffer
      ]
      Tracker.flush()

      test.equal randomBuffer.bufferNumber(), 1, "Launch #{launchNumber} selects the loaded sample"
      test.equal randomBuffer.selectedBuffer(), buffer

    finally
      audio?.destroy()
      Blaze.remove view unless view.isDestroyed
