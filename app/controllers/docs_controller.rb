class DocsController < ApplicationController

  DOCS_DIR = Rails.root.join("docs")

  def show
    @slug = params[:page] || "getting_started"
    @path = resolve_doc_path(@slug)
    @sidebar = build_sidebar

    @content = markdown.render(File.read(@path))
  end

  def whats_new_updates
    @slug = "_whats_new_updates"
    @path = resolve_doc_path(@slug)

    unless @path && File.exist?(@path)
      return render plain: "What's New doc not found", status: :not_found
    end

    @markdown_content = File.read(@path)
    @updates = extract_highlights(@markdown_content)
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(with_toc_data: true),
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )
  end

  def resolve_doc_path(slug)
    path = DOCS_DIR.join("#{slug}.md")
    return path if File.exist?(path)

    # Try subdirectories
    full_slug = slug.split("/")
    path = DOCS_DIR.join(*full_slug) # handles subfolders
    path.sub_ext(".md") if File.exist?(path.sub_ext(".md"))
  end

  def build_sidebar
    sidebar = {}

    Dir.glob("#{DOCS_DIR}/**/*.md").sort.each do |filepath|
      rel_path = Pathname(filepath).relative_path_from(DOCS_DIR)
      folder = rel_path.dirname.to_s == "." ? "General" : rel_path.dirname.to_s.titleize
      page_slug = rel_path.sub_ext("").to_s

      next if page_slug.first == "_"

      sidebar[folder] ||= []
      sidebar[folder] << {
        title: page_slug.split("/").last.titleize,
        slug: page_slug
      }
    end

    sidebar
  end

  def extract_highlights(content)
    sections = content.split(/^> highlight$/).reject(&:blank?)

    sections.first(3).map do |section|
      next unless section.present?

      version = section.match(/### \[(.*?)\]/)&.captures&.first
      date = section.match(/- (.*?)$/)&.captures&.first
      changes = section.scan(/^- (.*?)$/).flatten

      {
        version: version,
        date: date,
        changes: changes,
        image: section.match(/!\[.*?\]\((.*?)\)/)&.captures&.first
      }
    end.compact
  end
end
