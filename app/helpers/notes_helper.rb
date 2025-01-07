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

    # Handle text formatting
    formatted_content = formatted_content.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>') # bold
    formatted_content = formatted_content.gsub(/\*(.+?)\*/, '<em>\1</em>')             # italic
    formatted_content = formatted_content.gsub(/\_\_(.+?)\_\_/, '<u>\1</u>')           # underline
    formatted_content = formatted_content.gsub(/\~\~(.+?)\~\~/, '<del>\1</del>')       # strikethrough
    formatted_content = formatted_content.gsub(/\=\=(.+?)\=\=/, '<mark>\1</mark>')     # highlight

    # Split content into paragraphs first
    paragraphs = formatted_content.split(/\n\n+/)
    
    formatted_paragraphs = paragraphs.map do |paragraph|
      lines = paragraph.split("\n")
      in_list = false
      list_type = nil
      list_count = 0
      
      processed_lines = []
      
      lines.each do |line|
        if line.start_with?('# ')
          processed_lines << "<h1>#{line[2..]}</h1>"
        elsif line.start_with?('## ')
          processed_lines << "<h2>#{line[3..]}</h2>"
        elsif line.start_with?('### ')
          processed_lines << "<h3>#{line[4..]}</h3>"
        elsif line.start_with?('- ')
          if !in_list || list_type != :ul
            processed_lines << (in_list ? "</#{list_type}><ul>" : "<ul>")
            in_list = true
            list_type = :ul
          end
          processed_lines << "<li>#{line[2..]}</li>"
        elsif line.match?(/^\d+\.\s/)
          if !in_list || list_type != :ol
            processed_lines << (in_list ? "</#{list_type}><ol>" : "<ol>")
            in_list = true
            list_type = :ol
            list_count = 0
          end
          list_count += 1
          processed_lines << "<li>#{line.sub(/^\d+\.\s/, '')}</li>"
        else
          if in_list
            processed_lines << "</#{list_type}>"
            in_list = false
            list_type = nil
          end
          processed_lines << line
        end
      end
      
      processed_lines << "</#{list_type}>" if in_list
      
      if processed_lines.any? { |line| line.start_with?('<ul>', '<ol>', '<h1>', '<h2>', '<h3>') }
        processed_lines.join("\n")
      else
        processed_lines.join("<br>")
      end
    end

    # Wrap non-heading paragraphs and make it safe
    formatted_paragraphs.map do |p| 
      if p.start_with?('<h1>', '<h2>', '<h3>')
        p
      else
        "<p>#{p}</p>"
      end
    end.join.html_safe
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
