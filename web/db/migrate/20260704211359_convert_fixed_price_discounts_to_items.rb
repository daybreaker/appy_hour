class ConvertFixedPriceDiscountsToItems < ActiveRecord::Migration[8.1]
  # Lightweight, enum-free models so this migration is independent of the
  # app models (which drop the fixed_price enum value in the same change).
  class Generic < ActiveRecord::Base
    self.table_name = "happy_hour_generics"
  end

  class Item < ActiveRecord::Base
    self.table_name = "happy_hour_items"
  end

  FIXED_PRICE = 2 # old HappyHourGeneric.discount_type value

  def up
    Generic.where(discount_type: FIXED_PRICE).find_each do |generic|
      Item.create!(
        happy_hour_id: generic.happy_hour_id,
        name: generic.applies_to.presence || "Item",
        happy_hour_price: generic.discount_value,
        description: generic.description,
        status: generic.status, # same integer status values as HappyHourItem
        created_at: generic.created_at,
        updated_at: generic.updated_at
      )
      generic.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
