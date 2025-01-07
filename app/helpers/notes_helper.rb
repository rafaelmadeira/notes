module NotesHelper
  def format_note_content(content)
    formatted_content = content.dup

    # First, handle full note embeds at the start
    formatted_content = formatted_content.gsub(/\A\[\[(\d+)\]\]/) do |match|
      note_id = $1
      if referenced_note = Note.find_by(id: note_id)
        <<~HTML
          <div class="embedded-note">
            <a href="#{note_path(referenced_note)}">[#{note_id}]</a>
            <blockquote>
              #{simple_format(referenced_note.content)}
            </blockquote>
          </div>
        HTML
      else
        match
      end
    end

    # Handle inline references with custom text
    formatted_content = formatted_content.gsub(/\(([^)]+)\)\[\[(\d+)\]\]/) do |match|
      text = $1
      note_id = $2
      if Note.exists?(note_id)
        "<a href=\"#{note_path(note_id)}\">#{text}</a>"
      else
        match
      end
    end

    # Handle simple inline references
    formatted_content = formatted_content.gsub(/\[\[(\d+)\]\]/) do |match|
      note_id = $1
      if Note.exists?(note_id)
        "<a href=\"#{note_path(note_id)}\">[#{note_id}]</a>"
      else
        match
      end
    end

    # Handle hashtags
    formatted_content = formatted_content.gsub(/(?<=\s|^)#(\w+)/) do |match|
      tag = $1
      "<a href=\"#{notes_path(tag: tag)}\" class=\"tag\">##{tag}</a>"
    end

    # Convert line breaks to HTML and make it safe
    simple_format(formatted_content)
  end
end
