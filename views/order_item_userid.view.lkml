view: order_item_userid {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: count {}
      column: total_gross_revenue {}
    }
  }
  dimension: user_id {
    type: number
  }

  dimension: count {
    type: number
  }

  dimension: order_group {
    type: tier
    tiers: [0,1,2,3,6,10]
    sql: ${count} ;;
    style: integer
  }

  dimension: total_gross_revenue {
    type: number
    value_format_name: usd
  }

  dimension: revenue_group {
    type: tier
    tiers: [0,5,20,50,100,500,1000]
    sql: ${total_gross_revenue} ;;
    style: integer
    value_format_name: usd
  }

  measure: number_of_orders {
    type: sum
    sql:  ${count} ;;
    value_format_name: decimal_0
  }

  measure: lifetime_revenue {
    type: sum
    sql: ${total_gross_revenue} ;;
    value_format_name: usd

  }
}
