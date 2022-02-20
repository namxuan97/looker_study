view: order_frequency {
  derived_table: {
    sql: select
      id,
      order_id,
      user_id,
      sale_price,
      status,
      created_at,
      lag(created_at) over (partition by user_id order by created_at) as next_order_date

      from order_items
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
    primary_key: yes
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: next_order_date {
    type: time
    sql: ${TABLE}."NEXT_ORDER_DATE" ;;
  }

  dimension: is_first_purhcase {
    type: yesno
    sql: ${next_order_date_raw} is null ;;
  }

  dimension: day_between_order {
    type: number
    sql: datediff('day',${created_at_raw}, ${next_order_date_raw}) ;;
  }

  set: detail {
    fields: [
      id,
      order_id,
      user_id,
      sale_price,
      status,
      created_at_time,
      next_order_date_time
    ]
  }
}
