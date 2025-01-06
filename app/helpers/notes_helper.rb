module NotesHelper
  def format_content_with_tags(content)
    content.gsub(/#\w+/) do |tag|
      link_to tag, notes_path(tag: tag.delete('#')), class: 'tag-link'
    end.html_safe
  end
end
