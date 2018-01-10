AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Browser extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Browser'

  constructor: (@computer) ->
    super

  onCreated: ->
    super

    @url = new ReactiveField 'https://retropolis.city/academy-of-art'
    @currentRoute = new ReactiveField null

    @autorun (computation) =>
      return unless url = @url()

      match = url.match /^https?:\/\//
      unless match
        # We need to add the protocol.
        @url "http://#{url}"
        return

      # Determine if we can serve the webpage ourselves or we need an iframe. Also make sure this is a valid url.
      match = url.match /^https?:\/\/(.*?)(\/.*)?$/
      [match, host, path] = match

      path ?= "/"

      {route, matchData} = AB.Router.findRoute host, path

      # We want to blacklist Adventure routes.
      route = null if route?.pageClass is LOI.Adventure or route?.pageClass.prototype instanceof LOI.Adventure

      @currentRoute route

  renderWebpage: ->
    return null unless currentRoute = @currentRoute()

    # We instantiate the page so that we can send the instance to the Render component. If it was just a class, it
    # would treat it as a function and try to execute it instead of pass it as the context to the Render component.
    layoutData =
      page: new currentRoute.pageClass

    new Blaze.Template =>
      Blaze.With layoutData, =>
        currentRoute.layoutClass.renderComponent @

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton
      'change .url-input': @onChangeUrlInput
      'click a': @onClickAnchor

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop

  onChangeUrlInput: (event) ->
    url = $(event.target).val()
    @url url

  onClickAnchor: (event) ->
    # Do not react if modifier keys are present (the user might be trying to open the link in a new tab).
    return if event.metaKey or event.ctrlKey or event.shiftKey

    link = event.currentTarget
    location = $("<a href='#{@url()}'>")[0]

    @url "#{location.protocol}//#{location.hostname}#{link.pathname}"
    event.preventDefault()

    # Browsers scroll to top on URL change.
    @$('.webpage').scrollTop(0)
