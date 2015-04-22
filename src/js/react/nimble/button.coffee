React = require 'react'

ServicesIcons = require '../../taist/servicesIcons'

{ div } = React.DOM

NimbleButton = React.createFactory React.createClass
  getInitialState: ->
    editButtonFocusClass: ''

  onClick: ->
    @props.onClick?()

  render: ->
    div {
      tabIndex: 0
      className: "nmbl-Button nmbl-Button-WebkitGecko #{@state.editButtonFocusClass}"
      onMouseEnter: => @setState editButtonFocusClass: 'nmbl-Button-focus'
      onMouseLeave: => @setState editButtonFocusClass: ''
      onClick: @onClick
    },
      div {
        className: 'nmbl-ButtonContent'
        style:
          backgroundImage: ServicesIcons.getURL @props.serviceIcon
          backgroundSize: @props.iconSize ? 'contain'
          backgroundRepeat: 'no-repeat'
          paddingLeft: 24
      }, @props.text

module.exports = NimbleButton