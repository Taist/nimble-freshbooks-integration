React = require 'react'

{ div, table, tbody, tr, h2, a, select, option } = React.DOM

NimbleButton = require './button'

td = () ->
  props = arguments[0]

  unless props.style?
    props.style = {}

  props.style.padding = "4px 8px"
  React.DOM.td.apply @, arguments

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

  # onSelectContact: ->
  #   newValue = @refs.select.getDOMNode().value
  #   @props?.onSelectContact @props.dict.id, newValue

  render: ->
    div {},

      unless @props.fbEstimateLink?
        div { style: textAlign: 'right' },

          if @props.companyMembers
            select {
              ref: 'select'
              # onChange: @onSelectContact
            },
              @props.companyMembers.map (m) =>
                option { key: m.id, value: m.id }, "#{m.first_name} #{m.last_name} (#{m.email})"

          div { style: marginLeft: 10, display: 'inline-block' },
            NimbleButton {
              text: 'Create estimate'
              serviceIcon: 'freshbooks'
              iconSize: 16
              useSpinner: true
              isSpinnerActive: @props.isSpinnerActive
              onClick: @props.onCreateEstimate
            }

      if @props?.error?
        div {
          style:
            textAlign: 'center'
            color: 'salmon'
            fontStyle: 'italic'
        }, @props.error

      if @props.fbEstimateLink?
        table { style: width: '100%' },
          tbody {},
            tr {},
              td { colSpan: 3 },
                h2 { style: marginBottom: 12 }, "Estimate: #{@props.number}"

              td { colSpan: 4, style: textAlign: 'right' },

                div { style: display: 'inline-block' },
                  a {
                    href: @props.fbEstimateLink
                    target: '_blank'
                    style:
                      display: 'inline-block'
                  },
                    NimbleButton { text: 'Edit estimate', serviceIcon: 'freshbooks' }

                unless @props?.bidsketchProposalViewLink?
                  div { style: display: 'inline-block', marginLeft: 10 },
                    NimbleButton {
                      text: 'Create proposal'
                      serviceIcon: 'bidsketch'
                      iconSize: 16
                      onClick: @props.onCreateProposal
                      isSpinnerActive: @props.isSpinnerActive
                      useSpinner: true
                    }
                else
                  div { style: display: 'inline-block', marginLeft: 10 },
                    a {
                      href: @props.bidsketchProposalEditLink
                      target: '_blank'
                      style:
                        display: 'inline-block'
                    },
                      NimbleButton { text: 'Edit proposal', serviceIcon: 'bidsketch', iconSize: 16 }

                    a {
                      href: @props.bidsketchProposalViewLink
                      target: '_blank'
                      style:
                        display: 'inline-block'
                        marginLeft: 10
                    },
                      NimbleButton { text: 'View proposal', serviceIcon: 'pdf', iconSize: 17 }

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
