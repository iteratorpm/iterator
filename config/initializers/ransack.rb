Ransack.configure do |config|
  # Change default search parameter key name.
  # Default key name is :q
  config.search_key = :q

  # Raise errors if a query contains an unknown predicate or attribute.
  # Default is true (do not raise error on unknown conditions)
  config.ignore_unknown_conditions = false

  # Globally display sort links without the order indicator arrow.
  # Default is false (sort order indicators are displayed)
  config.hide_sort_order_indicators = true

  # Add custom predicates
  config.add_predicate 'has_attachment',
    arel_predicate: 'exists',
    formatter: proc { |v| v ? Attachment.where('attachable_id = stories.id AND attachable_type = ?', 'Story').arel.exists : nil },
    validator: proc { |v| v.present? },
    type: :boolean

  config.add_predicate 'has_blocker',
    arel_predicate: 'exists',
    formatter: proc { |v| v ? Blocker.where('story_id = stories.id').arel.exists : nil },
    validator: proc { |v| v.present? },
    type: :boolean

  # Enable wildcard searches
  config.add_predicate 'contains',
    arel_predicate: 'matches',
    formatter: proc { |v| "%#{v}%" },
    validator: proc { |v| v.present? },
    type: :string

  # Enable array searches for comma-separated values
  config.add_predicate 'in_array',
    arel_predicate: 'in',
    formatter: proc { |v| v.split(',') },
    validator: proc { |v| v.present? },
    type: :string
end
