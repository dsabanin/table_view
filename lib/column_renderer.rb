class TableView

  class ColumnRenderer
  
    attr_reader :params, :controller
  
    def initialize(params, controller)
      @params     = params
      @controller = controller
    end
  
    def header(column)
      label = column.human_name
      if column.not_sortable?
        field = label
      else
        field = link_to(label, url_hash_for(column))
      end
      helpers.content_tag(:th, "#{field}&nbsp;#{render_sort_order(column)}", column.options[:th])
    end

    def render_sort_order(column)
      if column.active?
        '<span class="sort">%s</span>' % (column.ascending? ? '&darr;' : '&uarr;')
      end
    end
    
    def url_hash_for(column)
      {
        params.sort_by_field_name => column,
        params.sort_order_name    => column.reverse_sort_order
      }
    end
  
    def helpers
      ActionController::Base.helpers
    end

    def link_to(label, url_hash)
      controller.instance_variable_get(:@template).link_to(label, :overwrite_params => url_hash)
    end

  end
  
end