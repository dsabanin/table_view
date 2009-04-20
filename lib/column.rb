class TableView
  
  class Column
  
    attr_reader   :options
    attr_accessor :sort_order
  
    def initialize(column, options={})
      @column     = column.to_s
      @options    = options
      @active     = false
      @sort_order = "desc"
    end
  
    def human_name
      options[:label] || @column.humanize
    end
  
    def == other
      self.to_s == other.to_s
    end
    
    def active?
      @active
    end
  
    def active!
      @active = true
    end
  
    def sql_column_name_and_order
      "#{self} #{sort_order}"
    end
  
    def render_sort_order
      if active?
        '<span class="sort">%s</span>' % (ascending? ? '&darr;' : '&uarr;')
      end
    end

    def reverse_sort_order
      if ascending? then "desc" else "asc" end
    end

    def ascending?
      sort_order == "asc"
    end

    def descending?
      not ascending?
    end
  
    def text?
      options[:text]
    end
  
    def to_s
      @column
    end

    def to_param
      to_s
    end
  
  end

end