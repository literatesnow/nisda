require 'cgi'

# Generates monthly photo page HTML.
class PhotoPage
  @sections = []

  def initialize(sections)
    @sections = sections
  end

  # {{{ html_page_top
  def html_page_top
    <<~HTML
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    <html>
      <head>
        <title>Chris :: Photos</title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <meta name="author" content="Chris">
        <meta name="generator" content="vim7">
        <meta property="og:url" content="https://www.nisda.net/photos.html">
        <meta property="og:type" content="article">
        <meta property="og:title" content="Photos">
        <meta property="og:description" content="Latest photos.">
        <meta property="og:image" content="https://www.nisda.net/images/landscape.png">
        <link rel="stylesheet" href="blip.css" type="text/css">
        <link rel="stylesheet" href="assets/lookthing/lookthing.css" type="text/css">
        <script type="text/javascript" src="assets/lookthing/lookthing.js"></script>
        <script type="text/javascript">
          document.addEventListener('DOMContentLoaded', function() {
            new LookThing({
              imageLicense: {
                name: 'CC BY-SA 4.0',
                uri: 'https://creativecommons.org/licenses/by/4.0/'
              },
              baseDir: 'assets/lookthing/'
            });
          }, true);
        </script>
      </head>

      <body>
        <div id="top">
          <div class="logo"><a href="/">Chris</a></div>

          <div class="catchline">Digitally Remastered For Success</div>
        </div>

        <div id="left">
          <div class="box">
            <div class="ht"><a href="/">Main</a></div>
          </div>

          <div class="box">
            <div class="hm">Projects</div>

            <div class="hs"><a href="superfluous.html">Superfluous</a></div>
            <div class="hs"><a href="arise.html">Arise</a></div>
            <div class="hs"><a href="fizz.html">Fizz</a></div>
            <div class="hs"><a href="watcher.html">Watcher</a></div>
            <div class="hs"><a href="crank.html">crank</a></div>
            <div class="hs"><a href="raddns.html">RadDNS</a></div>
            <div class="hs"><a href="personified.html">Personified</a></div>
          </div>

          <div class="box">
            <div class="hm">Games</div>

            <div class="hs"><a href="quake.html">Quake</a></div>
            <div class="hs"><a href="battlefield.html">Battlefield</a></div>
          </div>

          <div class="box">
            <div class="ht"><a href="photos.html">Photos</a></div>
            <div class="ht"><a href="source.html">Source Code</a></div>
            <div class="ht"><a href="contact.html">Contact</a></div>
          </div>

          <div class="box">
            <img class="centerimage" src="images/lemming.png" alt="Lemming">
          </div>
        </div>

        <div id="center">
          <div class="content">
            <h1><a name="Photos">Photos</a></h1>
          </div>

          <div class="content">
    HTML
  end
  # }}}

  # {{{ html_page_bottom
  def html_page_bottom
    <<~HTML
          </div>

          <div class="content">
            <div class="blocktext">
              <a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/"><img style="display: block;" alt="Creative Commons License" src="images/cc-by-sa-80x15.png"></a>
            All photos are licensed under a Creative Commons <a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">Attribution-ShareAlike 4.0</a> International License.
            </div>
          </div>
        </div>
      </body>

    </html>
    HTML
  end
  # }}}

  def build_page
    html = []
    html << html_page_top

    unless @sections.empty?
      @sections.each do |section|
        html << html_heading(section[:date])

        attribution_name = 'Chris'
        attribution_uri  = "https://www.nisda.net/photos/#{section[:date]}"

        section[:sub].each do |sub|
          html << html_tags(sub[:tags])
          html << html_photo_list(sub[:tags], sub[:photos], attribution_name, attribution_uri)
        end
      end
    else
      html << 'No current photos.'
    end

    html << html_page_bottom
    html.join("\n")
  end

  def html_heading(date)
    <<~HTML
      <h2 class="photodate">
        <a name="photos-#{CGI.escapeHTML(date)}">#{CGI.escapeHTML(date)}</a>
      </h2>
    HTML
  end

  def html_tags(tags)
    <<~HTML
    <div class="phototags">
      #{tags.map { |tag| "<span>#{CGI.escapeHTML(tag)}</span>" }.join("\n")}
    </div>
    HTML
  end

  def html_photo_list(tags, photos, attribution_name, attribution_uri)
    html   = []
    html << '<ul class="photolist">'

    tags = tags.join ', '

    photos.each do |photo|
      title = "NISDA_#{File.basename photo[:fileName], '.*'}"
      desc  = "Tags: #{tags}, Photo date: #{photo[:imageDate]}"

      html << <<~HTML
        <li>
          <a href="images/photos/#{CGI.escapeHTML photo[:fileName]}"
             data-lookthing="href"
             data-lookthing-title="#{CGI.escapeHTML title}"
             data-lookthing-desc="#{CGI.escapeHTML desc}"
             data-lookthing-attribution-name="#{CGI.escapeHTML attribution_name}"
             data-lookthing-attribution-uri="#{CGI.escapeHTML attribution_uri}">
            <img src="images/photos/thumbs/#{CGI.escapeHTML photo[:fileName]}"
                 alt="#{CGI.escapeHTML desc}">
          </a>
        </li>
      HTML
    end

    html << '</ul>'
    html.join "\n"
  end
end
