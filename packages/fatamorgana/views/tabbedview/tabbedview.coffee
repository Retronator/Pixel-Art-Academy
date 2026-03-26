AM = Artificial.Mirage
FM = FataMorgana

class FM.TabbedView extends FM.View
  # tabs: array of tabs shown in this view
  #   caption: the text identifying the tab
  #   active: true for the tab that is currently expanded
  # allowClosing: boolean whether the active tab can be closed by clicking on it
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
    return unless activeTabIndex >= 0

    tabbedViewData.child "tabs.#{activeTabIndex}"

  overrideAreaSize: ->
    # We want to control the size of the area when no tab is selected.
    not @activeTabData()

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab

  onClickTab: (event) ->
    clickedTab = @currentData()
    tabbedViewData = @data()
    tabbedViewDataValue = tabbedViewData.value()

    if tabbedViewDataValue.allowClosing ? true
      # If we clicked an active tab we need to close all tabs.
      setToFalse = clickedTab.active

    for tab, index in tabbedViewDataValue.tabs
      value = if setToFalse then false else tab is clickedTab

      tabbedViewData.child("tabs.#{index}").set 'active', value
