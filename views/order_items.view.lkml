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
      week,
      month,
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

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
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

  dimension: is_valid_oder {
    type:  yesno
    sql:  ${sale_price} not in ("cancelled","returned");;
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
}
