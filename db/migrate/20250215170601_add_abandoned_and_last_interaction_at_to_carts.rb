class AddAbandonedAndLastInteractionAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, default: false
    add_column :carts, :last_interaction_at, :datetime
  end
end
