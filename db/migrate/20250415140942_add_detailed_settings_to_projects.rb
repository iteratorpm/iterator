class AddDetailedSettingsToProjects < ActiveRecord::Migration[8.0]
  def change
    change_table :projects do |t|
      # General
      t.string :title
      t.string :description
      t.references :organization, foreign_key: true # Assumes `organizations` table exists
      t.boolean :enable_tasks, default: true

      # Privacy
      t.boolean :public_access, default: false

      # Iterations and Velocity
      t.integer :iteration_start_day, default: 0   # enum: { sunday: 0, monday: 1, ... }
      t.date    :project_start_date
      t.integer :project_time_zone, default: 0     # enum: e.g., { est: 0, cst: 1, pst: 2, ... }
      t.integer :iteration_length, default: 1
      t.integer :point_scale, default: 0           # enum: { linear_0123: 0, fibonacci: 1, tshirt: 2 }
      t.string :point_scale_custom, default: ""
      t.integer :initial_velocity, default: 10
      t.integer :velocity_strategy, default: 0     # enum: { average_3: 0, last_iteration: 1 }
      t.integer :done_iterations_to_show, default: 4
      t.boolean :auto_iteration_planning, default: true

      # Access
      t.boolean :allow_api_access, default: true
      t.boolean :enable_incoming_emails, default: true
      t.boolean :hide_email_addresses, default: false

      # Customization
      t.boolean :priority_field_enabled, default: false
      t.integer :priority_display_scope, default: 0 # enum: { icebox_only: 0, all_panels: 1 }

      # Experimental
      t.boolean :point_bugs_and_chores, default: false
    end
  end
end
