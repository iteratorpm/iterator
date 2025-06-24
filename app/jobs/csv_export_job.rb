class CsvExportJob < ApplicationJob
  queue_as :default

  def perform(export_id)
    export = CsvExport.find(export_id)
    export.update(status: 'processing')

    # Generate filename
    export.generate_filename!
    path = export.full_file_path

    # Generate and write CSV
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, generate_csv(export))

    export.update(
      status: 'completed',
      filesize: File.size(path)
    )
  rescue => e
    export.update(status: 'failed')
    raise e
  end

  private

  def generate_csv(export)
    project = export.project
    CSV.generate do |csv|
      csv << ["Id", "Name", "Labels", "Type", "Estimate", "Current State", "Created at", "Description"]

      if export.options.include?('include_done_stories')
        project.stories.where(state: 'accepted').find_each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_current_backlog_stories')
        project.stories.where.not(state: ['unscheduled', 'accepted']).find_each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_icebox_stories')
        project.stories.where(state: 'unscheduled').find_each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_epics')
        project.epics.find_each do |epic|
          csv << [
            epic.id,
            epic.name,
            epic.label,
            'epic',
            nil,
            nil,
            epic.created_at,
            epic.description
          ]
        end
      end
    end
  end

  def story_to_csv_row(story)
    [
      story.id,
      story.name,
      story.labels.pluck(:name).join(','),
      story.story_type,
      story.estimate,
      story.state,
      story.created_at,
      story.description
    ]
  end
end
