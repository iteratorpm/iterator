class CsvImportService
  def initialize(project, csv_content)
    @project = project
    @csv_content = csv_content
    @results = { created: 0, updated: 0, errors: [] }
  end

  def import
    CSV.parse(@csv_content, headers: true) do |row|
      if row['Type'] == 'epic'
        import_epic(row)
      else
        import_story(row)
      end
    rescue => e
      @results[:errors] << "Row #{$.}: #{e.message}"
    end

    @results[:success] = @results[:errors].empty?
    @results
  end

  private

  def import_epic(row)
    if row['Id'].present?
      epic = @project.epics.find(row['Id'])
      epic.update!(epic_attributes(row))
      @results[:updated] += 1
    else
      @project.epics.create!(epic_attributes(row))
      @results[:created] += 1
    end
  end

  def import_story(row)
    if row['Id'].present?
      story = @project.stories.find(row['Id'])
      story.update!(story_attributes(row))
      @results[:updated] += 1
    else
      @project.stories.create!(story_attributes(row))
      @results[:created] += 1
    end
  end

  def epic_attributes(row)
    {
      title: row['Title'],
      label: row['Labels'],
      description: row['Description']
    }
  end

  def story_attributes(row)
    {
      title: row['Title'],
      story_type: row['Type'] || 'feature',
      estimate: row['Estimate'],
      state: row['Current State'] || 'unscheduled',
      description: row['Description'],
      created_at: parse_date(row['Created at']),
      labels_attributes: parse_labels(row['Labels'])
    }
  end

  def parse_date(date_str)
    date_str.present? ? Date.parse(date_str) : nil
  end

  def parse_labels(labels_str)
    return [] unless labels_str.present?
    labels_str.split(',').map do |label|
      { name: label.strip }
    end
  end
end
