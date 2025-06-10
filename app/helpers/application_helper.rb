module ApplicationHelper
 def render_markdown(content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true),
                                      autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(content || "").html_safe
 end

 def docs_path path=""
   "https://iteratorpm.com/docs/#{path}"
 end

 def changelog_path
   "https://iteratorpm.com/changelog"
 end
end
