class CsvExportJob < ApplicationJob
  queue_as :default

  def perform(export_id)
    export = CsvExport.find(export_id)
    export.update(status: 'processing')

    # Generate CSV content
    csv_content = generate_csv(export)

    # Save to file
    filename = "#{export.project.name.parameterize}_#{Time.now.to_i}-export.csv"
    file_path = Rails.root.join('storage', 'exports', "#{export.id}_#{filename}")

    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, csv_content)

    export.update(
      status: 'completed',
      filename: filename,
      filesize: File.size(file_path)
    )
  rescue => e
    export.update(status: 'failed')
    raise e
  end

  private

  def generate_csv(export)
    project = export.project
    CSV.generate do |csv|
      csv << ["Id", "Title", "Labels", "Type", "Estimate", "Current State", "Created at", "Description"]

      if export.options.include?('include_done_stories')
        project.stories.where(state: 'accepted').each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_current_backlog_stories')
        project.stories.where.not(state: ['unscheduled', 'accepted']).each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_icebox_stories')
        project.stories.where(state: 'unscheduled').each do |story|
          csv << story_to_csv_row(story)
        end
      end

      if export.options.include?('include_epics')
        project.epics.each do |epic|
          csv << [
            epic.id,
            epic.title,
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
      story.title,
      story.labels.pluck(:name).join(','),
      story.story_type,
      story.estimate,
      story.state,
      story.created_at,
      story.description
    ]
  end
end
