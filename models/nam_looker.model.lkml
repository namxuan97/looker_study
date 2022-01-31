connection: "snowlooker"

# include all the views
include: "/views/**/*.view"

datagroup: nam_looker_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: nam_looker_default_datagroup

explore: distribution_centers {}

explore: etl_jobs {}

explore: users {
  always_filter: {
    filters: [users.created_date: "before today"]
  }
}


explore: events {
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: [order_items.is_returned: "no", order_items.sale_price: "> 200",
              order_items.status: "Complete", order_items.count: "> 5" ]
  }

  conditionally_filter: {
    filters: [inventory_items.created_year: "last 2 years"]
    unless: [users.id]
  }

}

explore: order_item_userid {
  join:  users {
    type: left_outer
    sql_on:  ${order_item_userid.user_id} = ${users.id} ;;
    relationship: one_to_one
  }
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}
