React = require 'react'

{ div, button, a } = React.DOM

NimbleDealViewPage = React.createFactory React.createClass
  getInitialState: ->
    alertMessage: null
    focusClass: ''

  onCloseAlert: ->
     @setState alertMessage: null

  alertTimeout: 5 * 1000

  componentWillReceiveProps: (newProps) ->
    @setState { alertMessage: newProps.alertMessage }, ->
      if @state.alertMessage
        setTimeout =>
          @onCloseAlert()
        , @alertTimeout

  render: ->
    div { style: marginTop: 4 },
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
      div {},
        if @props.fbClientLink?
          a { href: @props.fbClientLink, target: '_freshBooks' }, 'Go to linked client on FreshBooks'
        else
          div {
            tabIndex: 0
            className: "nmbl-Button nmbl-Button-WebkitGecko #{@state.focusClass}"
            onMouseEnter: => @setState focusClass: 'nmbl-Button-focus'
            onMouseLeave: => @setState focusClass: ''
            onClick: @props.onCreateEstimate
          },
            div {
              className: 'nmbl-ButtonContent'
            }, 'Create FreshBooks Client'

module.exports = NimbleDealViewPage
