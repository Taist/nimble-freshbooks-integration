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

  onCreateEstimate: (event) ->
    @props.onCreateEstimate()

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
      div { style: marginTop: 4},
        if @props.fbEstimateLink?
          a { href: @props.fbEstimateLink, target: '_freshBooks' }, 'Estimate'
        else
          a {
            href: 'javascript:void(0)'
            onClick: @onCreateEstimate
          }, 'Create estimate'

module.exports = NimbleDealViewPage
