require 'cgi'

# Generates index photo page HTML.
class PhotoIndex
  def initialize(overview)
    @overview = overview
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
        <link rel="stylesheet" href="blip.css" type="text/css">
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
        </div>
      </body>

    </html>
    HTML
  end
  # }}}

  def build_page
    html = []
    html << html_page_top

    unless @overview.empty?
      html << '<ul>'
      @overview.each do |over|
        html << <<~HTML
          <li>
            #{CGI.escapeHTML over[:title]}:
            <a href="#{CGI.escapeHTML over[:file_name]}">#{CGI.escapeHTML over[:total].to_s} photos</a>
          </li>
          <ul>
            <li>#{CGI.escapeHTML over[:all_tags]}</li>
          </ul>
        HTML
      end
      html << '</ul>'
    else
      html << '<div>No current photos.</div>'
    end

    html << html_page_bottom
    html.join("\n")
  end
end
