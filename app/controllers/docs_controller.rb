class DocsController < ApplicationController

  DOCS_DIR = Rails.root.join("docs")

  def show
    @slug = params[:page] || "getting_started"
    @path = resolve_doc_path(@slug)

    unless @path && File.exist?(@path)
      return render plain: "Doc not found", status: :not_found
    end

    @markdown_content = File.read(@path)
    @content = markdown.render(@markdown_content)
    @sidebar = build_sidebar
  end

  def highlights
    markdown = File.read(resolve_doc_path("docs/whats_new"))
    sections = markdown.split(/^---$/)
    top_versions = sections.select { |s| s.include?('> highlight') }.first(3)

    highlights = top_versions.map do |section|
      version = section.match(/\[v(.*?)\]/)[1] rescue "Unknown"
      changes = section.scan(/^- (.+)$/).flatten
      {
        version: version,
        changes: changes
      }
    end

    render json: highlights
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

      sidebar[folder] ||= []
      sidebar[folder] << {
        title: page_slug.split("/").last.titleize,
        slug: page_slug
      }
    end

    sidebar
  end
end
