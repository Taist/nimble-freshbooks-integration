React = require 'react'

{ div } = React.DOM

NimbleDealViewPage = React.createFactory React.createClass
  getInitialState: ->
    alertMessage: null

  onCloseAlert: ->
     @setState alertMessage: null

  alertTimeout: 5 * 1000

  componentWillReceiveProps: (newProps) ->
    @setState {
      alertMessage: newProps.alertMessage
    }, ->
      if @state.alertMessage
        setTimeout =>
          @onCloseAlert()
        , @alertTimeout

  render: ->
    div {},
      div {},
        if @state.alertMessage?
          div {
            className: 'nmbl-StatusPanel nmbl-StatusPanel-warning'
            style:
              top: 60
              left: '50%'
              transform: 'translate(-50%, -50%)'
          },
            div { className: 'gwt-Label' }, @state.alertMessage
            div { className: 'closeOrange', onClick: @onCloseAlert }

module.exports = NimbleDealViewPage
