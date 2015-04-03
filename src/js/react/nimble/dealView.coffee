React = require 'react'

{ div, button } = React.DOM

NimbleDealViewPage = React.createFactory React.createClass
  getInitialState: ->
    focusClass: ''

  render: ->
    div { style: marginTop: 4 },
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
