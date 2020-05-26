AW = Artificial.Workforce

class AW.Work
  # Note: Function must contain the onmessage function defined on self (eg. self.onmessage = (message) ->).
  constructor: (@function) ->
    blob = new Blob ["(#{@function})()"], type: 'application/javascript'
    @functionDataURL = URL.createObjectURL blob

  createWorker: ->
    new Worker @functionDataURL
