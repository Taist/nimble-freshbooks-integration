React = require 'react'

ServicesIcons = require '../../taist/servicesIcons'

Spinner = require 'spin'

{ div } = React.DOM

NimbleButton = React.createFactory React.createClass
  getInitialState: ->
    editButtonFocusClass: ''
    isSpinnerActive: false

  onClick: ->
    unless @state.isSpinnerActive
      @setState { isSpinnerActive: true }, =>
        @props.onClick?()

  componentDidMount: ->
    if @props.useSpinner
      config =
        length: 4
        width: 2
        radius: 4
      @spinner = new Spinner config
      @spinner.spin @refs.spinnerContainer?.getDOMNode()

  componentWillReceiveProps: (newProps) ->
    @setState {
      isSpinnerActive: if newProps.isSpinnerActive is false then false else @state.isSpinnerActive
    }

  render: ->
    div {
      tabIndex: 0
      className: "nmbl-Button nmbl-Button-WebkitGecko #{@state.editButtonFocusClass}"
      onMouseEnter: => @setState editButtonFocusClass: 'nmbl-Button-focus'
      onMouseLeave: => @setState editButtonFocusClass: ''
      onClick: @onClick
      style:
        position: 'relative'
        width: 116
    },
      div {
        ref: 'spinnerContainer'
        style:
          position: 'absolute'
          left: '50%'
          top: '50%'
          transform: 'translate(-50%, -50%)'
          display: if @state.isSpinnerActive then '' else 'none'
      }

      div {
        className: 'nmbl-ButtonContent'
        style:
          backgroundImage: ServicesIcons.getURL @props.serviceIcon
          backgroundSize: @props.iconSize ? 'contain'
          backgroundRepeat: 'no-repeat'
          paddingLeft: 24
      }, @props.text

module.exports = NimbleButton
