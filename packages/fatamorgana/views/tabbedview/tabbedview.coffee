AM = Artificial.Mirage
FM = FataMorgana

class FM.TabbedView extends FM.View
  # tabs: array of tabs shown in this view
  #   caption: the text identifying the tab
  #   active: true for the tab that is currently expanded
  @id: -> 'FataMorgana.TabbedView'
  @register @id()

  onCreated: ->
    super arguments...
    
    @activeTabIndex = new ComputedField =>
      tabbedViewData = @data()
      _.findIndex tabbedViewData.get('tabs'), (tab) => tab.active

  activeClass: ->
    tab = @currentData()
    'active' if tab.active

  activeTabData: ->
    tabbedViewData = @data()
    activeTabIndex = @activeTabIndex()
    tabbedViewData.child "tabs.#{activeTabIndex}"

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab

  onClickTab: (event) ->
    clickedTab = @currentData()
    tabbedViewData = @data()

    # If we clicked an active tab we need to close all tabs.
    setToFalse = clickedTab.active

    for tab, index in tabbedViewData.value().tabs
      value = if setToFalse then false else tab is clickedTab

      tabbedViewData.child("tabs.#{index}").set 'active', value
