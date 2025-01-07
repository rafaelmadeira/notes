module NotesHelper
  def format_note_content(content)
    formatted_content = content.dup

    # First, handle full note embeds at the start
    formatted_content = formatted_content.gsub(/\A\[\[(\d+)\]\]/) do |match|
      note_id = $1
      if referenced_note = Note.find_by(id: note_id)
        render_embedded_note(referenced_note)
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
        "<a href=\"#{note_path(note_id)}\">##{note_id}</a>"
      else
        match
      end
    end

    # Handle hashtags
    formatted_content = formatted_content.gsub(/(?<=\s|^)#(\w+)/) do |match|
      tag = $1
      "<a href=\"#{notes_path(tag: tag)}\" class=\"tag\">##{tag}</a>"
    end

    # Handle line breaks:
    # 1. Replace double line breaks with temporary marker
    # 2. Replace single line breaks with <br>
    # 3. Replace markers with paragraphs
    formatted_content
      .gsub(/\n\n+/, "DOUBLE_BREAK")
      .gsub(/\n/, "<br>")
      .split("DOUBLE_BREAK")
      .map { |p| "<p>#{p}</p>" }
      .join
      .html_safe
  end

  def format_timestamp(datetime)
    full_timestamp = datetime.strftime("%Y-%m-%d %H:%M")
    
    seconds_ago = Time.current - datetime
    hours_ago = seconds_ago / 3600
    
    display_text = if hours_ago < 24
      if hours_ago < 1
        "#{(seconds_ago / 60).to_i}m"
      else
        "#{hours_ago.to_i}h"
      end
    elsif datetime.year == Time.current.year
      datetime.strftime("%b %-d")
    else
      datetime.strftime("%b %-d, %Y")
    end

    content_tag(:span, display_text, title: full_timestamp)
  end

  private

  def render_embedded_note(note)
    <<~HTML
      <div class="embedded-note" data-controller="embedded-note">
        <div class="embedded-note-content" data-embedded-note-target="content" data-action="click->embedded-note#toggle">
          #{format_note_content(note.content)}
          <div class="embedded-note-footer">
            <a href="#{note_path(note)}" class="embedded-note-timestamp" title="#{note.created_at.strftime("%Y-%m-%d %H:%M")}">
              #{format_timestamp(note.created_at)}
            </a>
          </div>
        </div>
      </div>
    HTML
  end
end
