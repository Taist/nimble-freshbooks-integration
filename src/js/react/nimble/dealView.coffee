React = require 'react'
Spinner = require 'spin'

{ div, button, a } = React.DOM

NimbleDealViewPage = React.createFactory React.createClass
  getInitialState: ->
    alertMessage: null
    focusClass: ''
    isSpinnerActive: false

  onCloseAlert: ->
     @setState alertMessage: null

  alertTimeout: 5 * 1000

  componentDidMount: ->
    config =
      length: 4
      width: 2
      radius: 4
    @spinner = new Spinner config
    @spinner.spin @refs.spinnerContainer?.getDOMNode()

  componentWillReceiveProps: (newProps) ->
    @setState {
      alertMessage: newProps.alertMessage
      isSpinnerActive: if newProps.isSpinnerActive is false then false else @state.isSpinnerActive
    }, ->
      if @state.alertMessage
        setTimeout =>
          @onCloseAlert()
        , @alertTimeout

  onCreateEstimate: (event) ->
    @setState isSpinnerActive: true, =>
      @props.onCreateEstimate()

  render: ->
    console.log @props
    console.log @state
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
        unless @props.fbEstimateLink?
          a {
            href: 'javascript:void(0)'
            onClick: @onCreateEstimate
          }, 'Create estimate'
        div {
          ref: 'spinnerContainer'
          style:
            position: 'relative'
            top: -4
            display: if @state.isSpinnerActive then 'inline-block' else 'none'
            marginLeft: 20
        }

module.exports = NimbleDealViewPage
