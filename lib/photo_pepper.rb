require 'json'
require 'date'

# Parse and group pepper files.
class PhotoPepper
  attr_reader :error_files

  def initialize(pepper_file, uri_prefix)
    @pepper_file = pepper_file
    @uri_prefix  = uri_prefix

    @photos_by_year_month = {}

    @error_files    = []
  end

  def parse
    group_photos_by_year_month read_pepper_file
  end

  def overview
    overview = []
    @photos_by_year_month.keys.sort.reverse.each do |year_month|
      overview << {
        file_name: "photos-#{year_month}.html",
        year_month: year_month,
        title:      DateTime.strptime(year_month, '%Y-%m').strftime('%B %Y'),
        total:      @photos_by_year_month[year_month].length
      }
    end
    overview
  end

  def photos(year_month)
    group_by_date_tags @photos_by_year_month[year_month]
  end

  def err_to_s
    @error_files.join "\n"
  end

  def most_recent_to_s
    year_month = @photos_by_year_month.keys.sort.last
    sections   = group_by_date_tags @photos_by_year_month[year_month]
    return year_month_to_s sections.first
  end

  private

  def year_month_to_s(section)
    str = '';
    return str if section.nil?

    str << "----------\n"
    str << "#{section[:date].to_s}\n"
    section[:sub].each do |sub|
      str << sub[:tags].join(', ')
      str << "\n"
    end
    str << "#{@uri_prefix}#{section[:date].gsub('-', '/')}\n" unless @uri_prefix.nil?
    str << "\n"
    str
  end

  def read_pepper_file
    JSON.parse File.read(@pepper_file), symbolize_names: true
  end

  def group_photos_by_year_month(pepper)
    pepper.each do |photo|
      begin
        image_date = DateTime.strptime photo[:imageDate], '%Y-%m-%d %H:%M:%S'
        group_str  = image_date.strftime '%Y-%m'
      rescue => e
        @error_files << "Skipping #{photo[:fileName]}: #{e} '#{photo[:imageDate]}'"
        next
      end

      @photos_by_year_month[group_str] = [] unless @photos_by_year_month[group_str]
      @photos_by_year_month[group_str] << photo
    end
  end

  # Group each photo by date and tags.
  def group_by_date_tags(photos)
    photos_by_date = {}
    tags_by_date   = {}

    photos.each do |photo|
      photo[:tags].sort!

      image_date = DateTime.strptime photo[:imageDate], '%Y-%m-%d %H:%M:%S'
      date_str   = image_date.strftime '%Y-%m-%d'
      tags_str = "#{date_str}-#{photo[:tags].join('_')}"

      photos_by_date[tags_str] = [] unless photos_by_date[tags_str]
      photos_by_date[tags_str] << photo

      tags_by_date[date_str] = {} unless tags_by_date[date_str]
      tags_by_date[date_str][tags_str] = photo[:tags]
    end

    create_sections tags_by_date, photos_by_date
  end

  # Each section is a date heading followed by tags and the
  # images associated with the tags.
  def create_sections(tags_by_date, photos_by_date)
    sections = []

    tags_by_date.each do |date, tags|
      section = { date: date,
                  sub:  [] }

      tags.keys.sort.each do |key|
        photos = photos_by_date[key]
        photos.sort! { |a, b| a[:image_date] <=> b[:image_date] }

        section[:sub] << { tags: tags[key],
                           photos: photos }
      end

      sections << section
    end

    # Newest sections first.
    sections.sort { |a, b| b[:date] <=> a[:date] }
  end

  def tags(year_month)
    tags = []
    @photos_by_year_month[year_month].each do |photo|
      tags += photo[:tags] if photo[:tags]
    end
    tags.uniq.sort
  end
end
