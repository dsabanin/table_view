class TableView

  class Params

    attr_reader :prefix, :controller, :params
      
    def initialize(prefix, controller)
      @prefix     = prefix
      @controller = controller
      @params     = controller.params
    end

    def current_page
      only_if_present params[page_number_name]
    end
  
    def page_number_name
      "#{prefix}_page"
    end

    def search_query
      only_if_present params[search_query_name]
    end
  
    def search_query_name
      "#{prefix}_search_by_text_fields"
    end

    def sort_by_field
      only_if_present params[sort_by_field_name]
    end

    def sort_by_field_name
      "sort_#{prefix}"
    end
  
    def sort_order
      only_if_present params[sort_order_name]
    end
  
    def sort_order_name
      "order_#{prefix}"
    end
  
    def each_filter(&block)
      params.each do |key, value|
        if value.present? and key =~ /#{prefix}_filter_by_(\w+)$/
          block.call($1, value.strip)
        end
      end
    end
  
  protected

    def only_if_present(object)
      if object.present?
        object
      else
        nil
      end
    end
  
  end

end