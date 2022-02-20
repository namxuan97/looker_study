view: customer_cohort {
  derived_table: {
    sql: with register_month_stg as
      (select
      id as user_id,
      min(date_trunc('month', created_at)::Date) as registered_month
      from public.users
      group by 1
      ),

      register_month as
      (select
      registered_month,
      count(distinct user_id) as numbers_of_registered_users
      from register_month_stg
      group by 1),

      cohort_month as
      (select
      registered_month,
      date_trunc('month',created_at)::date as purchase_month,
      sale_price,
      order_id,
      a.user_id
      from public.order_items a
      left join register_month_stg b
      on a.user_id = b.user_id)

      select
      a.registered_month,
      b.numbers_of_registered_users,
      purchase_month as user_purchase_month,
      datediff('month',a.registered_month,purchase_month) as purchase_month,
      sum(sale_price) as revenue,
      count(distinct order_id) as number_of_order,
      count(distinct user_id) as number_of_users
      from cohort_month a
      left join register_month b
      on a.registered_month = b.registered_month
      group by 1,2,3,4
       ;;
  }

  dimension: registered_month {
    type: date
    sql: ${TABLE}."REGISTERED_MONTH" ;;
  }

  dimension: purchase_month {
    type: number
    sql: ${TABLE}."PURCHASE_MONTH" ;;
  }

  dimension: user_purchase_month {
    type: date
    sql: ${TABLE}."USER_PURCHASE_MONTH" ;;
  }

  dimension: purchase_month_range {
    type:  tier
    tiers: [0,3,6,10,15,20,30]
    sql: ${purchase_month} ;;
    style: integer
  }

  dimension: purchase_today {
    type: yesno
    sql:  ${user_purchase_month} = date_trunc('month',current_date) and ${registered_month} <> date_trunc('month',current_date)    ;;

  }


  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: numbers_of_registered_users {
    type: number
    sql:  ${TABLE}."NUMBERS_OF_REGISTERED_USERS" ;;
  }

  dimension: number_of_order {
    type: number
    sql: ${TABLE}."NUMBER_OF_ORDER" ;;
  }

  dimension: number_of_users {
    type: number
    sql: ${TABLE}."NUMBER_OF_USERS" ;;
  }

  set: detail {
    fields: [registered_month, purchase_month, revenue, number_of_order, number_of_users]
  }


###MEASURE###
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_gross_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd

  }

  measure: total_orders {
    type: sum
    sql: ${number_of_order} ;;
  }

  measure: total_users {
    type: sum
    sql: ${number_of_users} ;;
  }

  measure: total_registered_user {
    type: max
    sql:  ${numbers_of_registered_users} ;;
  }

  measure: conversion {
    type: number
    sql: ${total_users}/${total_registered_user} ;;
    value_format_name: percent_0

  }

  measure: still_purchase_customers{
    type: sum
    sql: ${number_of_users}  ;;
    filters: [purchase_today: "yes"]

  }

  measure: purchase_today_of_total {
    type: number
    sql: ${still_purchase_customers}/${total_users} ;;
    value_format_name: percent_2

  }
}
