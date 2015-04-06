React = require 'react'

{ div, table, tbody, tr } = React.DOM

td = (props, data) ->
  unless props.style?
    props.style = {}

  props.style.padding = "4px 8px"
  React.DOM.td props, data

NimbleDealViewEstimateTable = React.createFactory React.createClass
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
      table { style: width: '100%' },
        tbody {},
          if @props.time?.length > 0
            tr { style: fontWeight: 'bold', borderBottom: '1px solid silver', lineHeight: '24px' },
              td {}, 'Task'
              td {}, 'Time Entry Notes'
              td { style: textAlign: 'right' }, 'Rate'
              td { style: textAlign: 'right' }, 'Hours'
              td {}, 'Tax'
              td {}, 'Tax'
              td { style: textAlign: 'right' }, 'LineTotal'
          @props.time.map (line) =>
            @createLine line
          if @props.time?.length > 0 and @props.item?.length > 0
            tr {}, td { colSpan: 7, style: height: 12 }, ''
          if @props.item?.length > 0
            tr { style: fontWeight: 'bold', borderBottom: '1px solid silver', lineHeight: '24px' },
              td {}, 'Item'
              td {}, 'Description'
              td { style: textAlign: 'right' }, 'UnitCost'
              td { style: textAlign: 'right' }, 'Qty'
              td {}, 'Tax'
              td {}, 'Tax'
              td { style: textAlign: 'right' }, 'LineTotal'
          @props.item.map (line) =>
            @createLine line

module.exports = NimbleDealViewEstimateTable
