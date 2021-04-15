# See the Pagy documentation: https://ddnexus.github.io/pagy/extras/foundation
# frozen_string_literal: true

require 'pagy/extras/shared'

class Pagy
  module Frontend

    # Pagination for Foundation: it returns the html with the series of links to the pages
    def pagy_foundation_nav(pagy)
      link = pagy_link_proc(pagy)

      html = +%(<nav class="pagy-foundation-nav" role="navigation" aria-label="Pagination"><ul class="pagination">)
      html << pagy_foundation_prev_html(pagy, link)
      pagy.series.each do |item| # series example: [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
        html << case item
                when Integer then %(<li>#{link.call item}</li>)                        # page link
                when String  then %(<li class="current">#{item}</li>)                  # active page
                when :gap    then %(<li class="ellipsis gap" aria-hidden="true"></li>) # page gap
                end
      end
      html << pagy_foundation_next_html(pagy, link)
      html << %(</ul></nav>)
    end

    # Javascript pagination for foundation: it returns a nav and a JSON tag used by the Pagy.nav javascript
    def pagy_foundation_nav_js(pagy, id=pagy_id)
      link = pagy_link_proc(pagy)
      tags = { 'before' => %(<ul class="pagination">#{pagy_foundation_prev_html pagy, link}),
               'link'   => %(<li>#{link.call PAGE_PLACEHOLDER}</li>),
               'active' => %(<li class="current">#{pagy.page}</li>),
               'gap'    => %(<li class="ellipsis gap" aria-hidden="true"></li>),
               'after'  => %(#{pagy_foundation_next_html pagy, link}</ul>) }

      html = %(<nav id="#{id}" class="pagy-foundation-nav-js" role="navigation" aria-label="Pagination"></nav>)
      html << pagy_json_tag(pagy, :nav, id, tags, pagy.sequels)
    end

    # Javascript combo pagination for Foundation: it returns a nav and a JSON tag used by the Pagy.combo_nav javascript
    def pagy_foundation_combo_nav_js(pagy, id=pagy_id)
      link    = pagy_link_proc(pagy)
      p_page  = pagy.page
      p_pages = pagy.pages
      input   = %(<input class="input-group-field cell shrink" type="number" min="1" max="#{p_pages}" value="#{p_page}" style="width: #{p_pages.to_s.length+1}rem; padding: 0 0.3rem; margin: 0 0.3rem;">)

      %(<nav id="#{id}" class="pagy-foundation-combo-nav-js" role="navigation" aria-label="Pagination"><div class="input-group">#{
          if (p_prev  = pagy.prev)
            link.call p_prev, pagy_t('pagy.nav.prev'), 'style="margin-bottom: 0px;" aria-label="previous" class="prev button primary"'
          else
            %(<a style="margin-bottom: 0px;" class="prev button primary disabled" href="#">#{pagy_t 'pagy.nav.prev'}</a>)
          end
      }<span class="input-group-label">#{pagy_t 'pagy.combo_nav_js', page_input: input, count: p_page, pages: p_pages}</span>#{
          if (p_next  = pagy.next)
            link.call p_next, pagy_t('pagy.nav.next'), 'style="margin-bottom: 0px;" aria-label="next" class="next button primary"'
          else
            %(<a style="margin-bottom: 0px;" class="next button primary disabled" href="#">#{pagy_t 'pagy.nav.next'}</a>)
          end
      }</div></nav>#{
          pagy_json_tag pagy, :combo_nav, id, p_page, pagy_marked_link(link)
      })
    end

    private

      def pagy_foundation_prev_html(pagy, link)
        if (p_prev = pagy.prev)
          %(<li class="prev">#{link.call p_prev, pagy_t('pagy.nav.prev'), 'aria-label="previous"'}</li>)
        else
          %(<li class="prev disabled">#{pagy_t 'pagy.nav.prev' }</li>)
        end
      end

      def pagy_foundation_next_html(pagy, link)
        if (p_next = pagy.next)
          %(<li class="next">#{link.call p_next, pagy_t('pagy.nav.next'), 'aria-label="next"'}</li>)
        else
          %(<li class="next disabled">#{pagy_t 'pagy.nav.next'}</li>)
        end
      end

  end
end
