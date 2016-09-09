AT = Artificial.Telepathy

class AT.RemoteServer
  constructor: (@urlOrConnection) ->
    throw new Meteor.Error 'argument-null', "Remote server needs to be initialized with an url string or a connection object." unless @urlOrConnection

    if _.isString @urlOrConnection
      @connection = DDP.connect @urlOrConnection

    else
      @connection = @urlOrConnection

    @_startupFunctions = []

    # Run all the startup functions on first connection.
    Meteor.autorun (computation) =>
      return unless @status().connected
      computation.stop()

      @_serverStarted = true
      startupFunction() for startupFunction in @_startupFunctions

  startup: (startupFunction) ->
    if @_serverStarted
      startupFunction()
      return

    @_startupFunctions.push Meteor.bindEnvironment startupFunction

  # DDP connection method proxies.
  subscribe: (args...) ->
    @connection.subscribe args...

  call: (args...) ->
    @connection.call args...

  methods: (args...) ->
    @connection.methods args...

  status: (args...) ->
    @connection.status args...
