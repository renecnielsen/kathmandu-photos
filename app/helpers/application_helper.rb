module ApplicationHelper
  include Twitter::Autolink

  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end

  def name_of_site
    ENV['NAME_OF_SITE'].presence || 'Coordstagram'
  end

  def page_header_subtitle
    anchor_text = %{
      <span class="glyphicon glyphicon-map-marker"></span>Dillibazaar
      }.html_safe

    %{
      Instagram photos taken within #{pluralize InstagramItem::MAX_DISTANCE_IN_METERS.to_i, 'meter'} of #{link_to anchor_text, '#', title: 'view map', class: 'map-link', 'data-toggle': 'modal', 'data-target': '#map-modal'}. Created by <a href="http://twitter.com/ReneCNielsen" target="_blank">@ReneCNielsen</a>.
    }.html_safe
  end

  def title_for(item)
    type = item.image? ? 'photo' : item.instagram_type
    "Instagram #{type} by #{item.full_data.user.full_name}"
  end

  def description_for(item)
    text = item.caption_text_with_extra_tags.to_s

    desc = "#{item.full_data.user.full_name} on Instagram"
    desc << ": #{text.first(130)}" if text.present?
    desc << "…" if text.length > 130

    desc
  end

  def meta_tags_for_index
    description_text = "Instagram photos and videos taken near the coordinates #{InstagramItem::CENTER_COORDINATES.join(', ')}"

    %{
      <link rel="canonical" href="#{root_url}"/>
      <meta name="description" content="#{description_text}"/>
      <meta property="og:title" content="#{description_text}"/>
      <meta property="og:url" content="#{root_url}"/>
      <meta property="og:site_name" content="#{name_of_site}"/>
    }.html_safe
  end

  def meta_tags_for(item)
    canonical_url = item_permalink_url(:path => item.path.sub(/^\/+/, ''))
    img_url = item.full_data.images.standard_resolution.url

    %{
      <link rel="canonical" href="#{canonical_url}"/>
      <meta name="description" content="#{description_for(item)}"/>
      <meta property="og:type" content="article"/>
      <meta property="og:title" content="#{description_for(item)}"/>
      <meta property="og:url" content="#{canonical_url}"/>
      <meta property="og:image" content="#{img_url}"/>
      <meta property="og:site_name" content="#{name_of_site}"/>
      <meta name="twitter:card" content="summary_large_image"/>
      <meta name="twitter:title" content="#{title_for(item)}"/>
      <meta name="twitter:description" content="#{description_for(item)}"/>
      <meta name="twitter:image:src" content="#{img_url}"/>
    }.html_safe
  end

  def google_analytics
    return unless Rails.env.production? && ENV['UA-62518204-1']

    %{
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '#{ENV['UA-62518204-1']}', 'auto');
        ga('send', 'pageview');
      </script>
    }.html_safe
  end

  def autolink_hashtags_and_users(text)
    auto_link(text.to_s, hashtag_url_base: 'http://websta.me/tag/',
                         username_url_base: 'http://instagram.com/',
                         url_class: nil,
                         hashtag_class: '',
                         username_class: nil,
                         username_include_symbol: true,
                         target_blank: true)
  end

  def formatted_and_linked_caption(item)
    simple_format(autolink_hashtags_and_users(item.caption_text_with_extra_tags))
  end

  def fork_me_on_github
    %{<a href="https://github.com/toddwschneider/coordstagram" target="_blank" class="hidden-xs hidden-sm"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67" alt="Fork me on GitHub"" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png"></a>}.html_safe
  end
end
