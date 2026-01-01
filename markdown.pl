require 'maruku'

def render_markdown(file)
  Maruku.new(File.read("content/en/#{file}.md", encoding: 'utf-8')).to_html
end

