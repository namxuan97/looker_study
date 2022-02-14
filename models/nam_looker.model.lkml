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

# explore: users {
#   conditionally_filter: {
#     filters: [users.created_date: "last 90 days"]
#     unless: [users.id,users.state]
#   }
# }


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

  # always_filter: {
  #   filters: [order_items.created_date: "last 30 days" ]
  # }

  conditionally_filter: {
    filters: [order_items.created_year: "last 2 years"]
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

explore: users {
  join:  order_item_userid {
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
