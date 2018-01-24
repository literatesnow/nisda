require 'json'
require 'date'

# Parse and group pepper files.
class PhotoPepper
  attr_reader :sections, :error_files

  def initialize(pepper_file, uri_prefix)
    @pepper_file = pepper_file
    @uri_prefix  = uri_prefix

    @photos_by_date = {}
    @tags_by_date   = {}

    @error_files    = []
  end

  def parse
    group_pepper read_pepper_file
    create_sections
  end

  def to_s
    str = '';
    unless sections.empty?
      sections.reverse.each do |section|
        str.concat "----------\n"
        str.concat "#{section[:date]}\n"
        section[:sub].each do |sub|
          str.concat sub[:tags].join(', ')
          str.concat "\n"
        end
        str.concat "#{@uri_prefix}#{section[:date]}\n" unless @uri_prefix.nil?
        str.concat "\n"
      end
    end
    str
  end

  private

  def read_pepper_file
    JSON.parse File.read(@pepper_file), symbolize_names: true
  end

  # Group each photo by date and tags.
  def group_pepper(pepper)
    pepper.each do |photo|
      begin
        image_date = DateTime.strptime photo[:imageDate], '%Y-%m-%d %H:%M:%S'
        date_str   = image_date.strftime '%Y-%m-%d'
      rescue => e
        @error_files << "Skipping #{photo[:fileName]}: #{e} '#{photo[:imageDate]}'"
        next
      end

      photo[:tags].sort!
      tags_str = "#{date_str}-#{photo[:tags].join('_')}"

      @photos_by_date[tags_str] = [] unless @photos_by_date[tags_str]
      @photos_by_date[tags_str] << photo

      @tags_by_date[date_str] = {} unless @tags_by_date[date_str]
      @tags_by_date[date_str][tags_str] = photo[:tags]
    end
  end

  # Each section is a date heading followed by tags and the
  # images associated with the tags.
  def create_sections
    @sections = []

    @tags_by_date.each do |date, tags|
      section = { date: date,
                  sub:  [] }

      tags.keys.sort.each do |key|
        photos = @photos_by_date[key]
        photos.sort! { |a, b| a[:image_date] <=> b[:image_date] }

        section[:sub] << { tags: tags[key],
                           photos: photos }
      end

      @sections << section
    end

    # Newest sections first.
    @sections.sort! { |a, b| b[:date] <=> a[:date] }
  end
end
