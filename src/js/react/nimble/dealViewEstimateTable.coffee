React = require 'react'

{ div, table, tbody, tr, h2, a } = React.DOM

td = (props, data) ->
  unless props.style?
    props.style = {}

  props.style.padding = "4px 8px"
  React.DOM.td props, data

NimbleDealViewEstimateTable = React.createFactory React.createClass
  getInitialState: ->
    editButtonFocusClass: ''

  createLine: (line) ->
    tr { key: line.name.$t, style: borderBottom: '1px solid silver' },
      td {}, line.name.$t
      td {}, line.description.$t
      td { style: textAlign: 'right' }, line.unit_cost.$t
      td { style: textAlign: 'right' }, line.quantity.$t
      td {}, line.tax1_name.$t
      td {}, line.tax2_name.$t
      td { style: textAlign: 'right' }, line.amount.$t

  render: ->
    div {},
      if @props?.amount?
        table { style: width: '100%' },
          tbody {},
            tr {},
              td { colSpan: 4 },
                h2 { style: marginBottom: 12 }, "Estimate: #{@props.number}"
              td { colSpan: 3, style: textAlign: 'right' },
                a {
                  href: @props.fbEstimateLink
                  target: '_blank'
                  style:
                    display: 'inline-block'
                },
                  div {
                    tabIndex: 0
                    className: "nmbl-Button nmbl-Button-WebkitGecko #{@state.editButtonFocusClass}"
                    onMouseEnter: => @setState editButtonFocusClass: 'nmbl-Button-focus'
                    onMouseLeave: => @setState editButtonFocusClass: ''
                  },
                    div {
                      className: 'nmbl-ButtonContent'
                    }, 'Edit'

            if @props.time?.length is 0 and @props.item?.length is 0
              tr {}, td { colSpan: 7, style: textAlign: 'center', fontStyle: 'italic' },
                'Estimate is empty'
            if @props.time?.length > 0
              tr { style: fontWeight: 'bold', borderBottom: '1px solid silver', lineHeight: '24px' },
                td {}, 'Task'
                td {}, 'Time Entry Notes'
                td { style: textAlign: 'right' }, 'Rate'
                td { style: textAlign: 'right' }, 'Hours'
                td {}, 'Tax'
                td {}, 'Tax'
                td { style: textAlign: 'right' }, 'Line Total'
            @props.time.map (line) =>
              @createLine line
            if @props.time?.length > 0 and @props.item?.length > 0
              tr {}, td { colSpan: 7, style: height: 2 }, ''
            if @props.item?.length > 0
              tr { style: fontWeight: 'bold', borderBottom: '1px solid silver', lineHeight: '24px' },
                td {}, 'Item'
                td {}, 'Description'
                td { style: textAlign: 'right' }, 'Unit Cost'
                td { style: textAlign: 'right' }, 'Qty'
                td {}, 'Tax'
                td {}, 'Tax'
                td { style: textAlign: 'right' }, 'Line Total'
            @props.item.map (line) =>
              @createLine line
            if @props.time?.length > 0 or @props.item?.length > 0
              tr {}, td { colSpan: 7, style: height: 2 }, ''
            if @props.time?.length > 0 or @props.item?.length > 0
              tr {},
                td { colSpan: 6, style: textAlign: 'right', fontWeight: 'bold' },
                  "Estimate Total (#{@props.currency})"
                td { style: textAlign: 'right', fontWeight: 'bold' }, @props.amount

module.exports = NimbleDealViewEstimateTable
