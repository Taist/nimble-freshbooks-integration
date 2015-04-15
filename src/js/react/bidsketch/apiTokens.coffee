React = require 'react'

{ div, a } = React.DOM

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
      'Linked to Nimble'
    else
      'Link to Nimble'

  render: ->
    div {
      style:
        height: 32
        opacity: if @state.isIntegrationEnabled then 1 else 0.7
        color: if @state.isIntegrationEnabled then 'gray' else 'black'
    },
      a {
        onClick: @onEnableIntegration
        id: 'control-button2'
        href: 'javascript:void(0)'
        style:
          position: 'relative'
          right: 0
          top: -2
      }, @getMessage()

module.exports = FreshBooksAPIEnablePage
