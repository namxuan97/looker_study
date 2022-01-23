view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_month,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }


  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: is_returned {
    type:  yesno
    sql:  ${returned_raw} is not NULL ;;
  }

  dimension: is_valid_oder {
    type:  yesno
    sql:  ${status} not in ('Cancelled','Returned');;
  }

  dimension: number_of_orders {
    type: number
    sql: 1 ;;

  }

  dimension: customers_group {
    type: tier
    tiers: [1,2,3,6,10]
    sql: ${number_of_orders} ;;

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }



  measure: total_sale_price {
    type: sum
    sql: ${sale_price};;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    type: running_total
    sql: ${sale_price};;
    value_format_name: usd
  }

  measure: gross_total_sale {
    type: sum
    sql: ${sale_price}
    value_format_name: usd;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price}
      value_format_name: usd;;
  }

  measure: total_gross_revenue {
    type: sum
    sql: ${sale_price};;
    value_format_name: usd
    filters: [
      is_valid_oder: "yes"
    ]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      inventory_items.product_name,
      inventory_items.id,
      users.last_name,
      users.id,
      users.first_name
    ]
  }

  measure: total_cost {
    type: sum
    sql:  ${inventory_items.cost};;
    value_format_name: usd
  }

  measure: averge_cost {
    type: average
    sql:  ${inventory_items.cost};;
    value_format_name: usd
  }

  measure: total_gross_margin {
    type: number
    sql:  ${total_gross_revenue}-${total_cost};;
    description: "gross revenue is calculated based on valid order(not returned or cancelled"
    value_format_name: usd
  }

  measure: average_gross_margin {
    type: average
    sql:  ${sale_price}-${inventory_items.cost};;
    value_format_name: usd
    filters: [
    is_valid_oder: "yes"
    ]
  }

  measure: P_gross_margin {
    type: number
    sql:  ${total_gross_margin}/nullif(${total_gross_revenue},0);;
    value_format_name: percent_1
  }

  measure: number_of_items_returned {
    type: count
    drill_fields: [detail*]
    filters: [
      is_returned: "yes"
    ]
  }

  measure: item_return_rate {
   type:  number
   sql:  ${number_of_items_returned}/nullif(${count},0) ;;
   value_format_name:  percent_1
  }

  measure: number_of_customers_returning_items {
    type: count_distinct
    sql: ${user_id};;
    filters: [
      is_returned: "yes"
    ]
  }

  measure: pct_of_users_with_return {
    type: number
    sql: ${number_of_customers_returning_items}/${users.count} ;;
  }

  measure: averge_spent_per_customers {
    type: number
    sql: ${total_gross_revenue}/${users.count};;
    value_format_name: decimal_0
  }

#for top 10
  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type: number
    sql: {% parameter max_rank %} ;;
  }

}
