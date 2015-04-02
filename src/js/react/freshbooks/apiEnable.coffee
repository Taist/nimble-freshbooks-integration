React = require 'react'

{ div, button } = React.DOM

FreshBooksAPIEnablePage = React.createFactory React.createClass
  getInitialState: ->
    isIntegrationEnabled: no

  onEnableIntegration: (event) ->
    event.preventDefault()
    @props.action?().then =>
      @setState isIntegrationEnabled: yes

  componentDidMount: () ->
    @setState isIntegrationEnabled: @props.isIntegrationEnabled

  componentWillReceiveProps: (nextProps) ->
    @setState isIntegrationEnabled: nextProps.isIntegrationEnabled

  getMessage: ->
    if @state.isIntegrationEnabled
      'Integration with Nimble enabled'
    else
      'Enable integration with Nimble'

  render: ->
    div { className: 'control-group' },
      div { className: 'control-label' }
      div { className: 'controls' },
        button {
          onClick: @onEnableIntegration
          className: "button large inline #{if @state.isIntegrationEnabled then 'green' else 'gray'}"
        }, @getMessage()

module.exports = FreshBooksAPIEnablePage
