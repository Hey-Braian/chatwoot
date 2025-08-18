class AddCachedLabelsList < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :cached_label_list, :string
    Conversation.reset_column_information
    # Removed deprecated ActsAsTaggableOn::Taggable::Cache call
  end
end
