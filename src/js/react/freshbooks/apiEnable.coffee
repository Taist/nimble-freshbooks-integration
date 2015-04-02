React = require 'react'

{ div, button } = React.DOM

FreshBooksAPIEnablePage = React.createFactory React.createClass
  onEnableIntegration: (event) ->
    event.preventDefault()

  render: ->
    div { className: 'control-group' },
      div { className: 'control-label' }
      div { className: 'controls' },
        button {
          onClick: @onEnableIntegration
          className: 'button large inline green'
        }, 'Enable integration with Nimble'

module.exports = FreshBooksAPIEnablePage
