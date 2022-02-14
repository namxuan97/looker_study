view: order_item_userid {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: count {}
      column: last_order_date {}
      column: first_order_date {}
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

  dimension: first_order_date {
    type: date
  }


  dimension: last_order_date {
    type: date
  }

  dimension: days_from_last_order{
    type: duration_day
    sql_start: ${last_order_date} ;;
    sql_end: current_timestamp() ;;

  }

  dimension: is_active {
    type: yesno
    sql: ${days_from_last_order} <= 90 ;;
  }

  dimension: repeat_customer {
    type: yesno
    sql: ${count} > 1 ;;

  }

  measure: number_of_orders {
    type: sum
    sql:  ${count} ;;
    value_format_name: decimal_0

  }

  measure: number_of_users {
    type: count
    drill_fields: [user_id]

  }


  measure: lifetime_revenue {
    type: sum
    sql: ${total_gross_revenue} ;;
    value_format_name: usd

  }

  measure: averge_day_since_last_order {
    type:  average
    sql: ${days_from_last_order} ;;
    value_format_name: decimal_0
  }

  measure: average_life_time_revenue{
    type:  average
    sql: ${total_gross_revenue} ;;
    value_format_name: usd

  }
}
