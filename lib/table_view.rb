# Following code depends on will_paginate plugin

require 'column'
require 'params'
require 'column_renderer'

class TableView
      
  attr_accessor :klass, :controller, :params, :columns, :source
  
  def initialize(klass, controller)
    @klass      = klass
    @source     = @klass
    @controller = controller
    @params     = Params.new(@klass.to_s.underscore.pluralize, @controller)
    @columns    = []
    yield(self) if block_given?
  end
  
  def column(*args)
    @columns << Column.new(*args)
  end
  
  def headers
    columns.map do |column|
      renderer.header(column)
    end.join("\n")
  end
  
  def paginated_items(options={})
    @_items ||= paginated_items_without_caching(options)
  end
  
  def count_items
    with_scope(filter_conditions) do
      with_scope(search_conditions) do
        source.count(:id, :distinct => true)
      end
    end
  end
  
  def to_will_paginate(args={})
    [@items, args.update(:param_name => params.page_number_name)]
  end
  
protected
  
  def paginated_items_without_caching(options)
    with_scope(filter_conditions) do
      with_scope(search_conditions) do
        options.update(
          :select => sql_select_statement, 
          :order  => sql_order_statement,
          :page   => params.current_page
        )
        source.paginate(options)
      end
    end
  end
  
  def columns
    @_prepared_columns ||= prepare_columns
  end
  
private

  def filter_conditions
    conds = {}
    params.each_filter do |field, value|
      conds[field] = value
    end
    conds
  end
  
  def search_conditions
    sql, vars  = "", []
    if params.search_query
      sql << text_columns.map { |col| " #{col} LIKE ? " }.join(" OR ")
      vars.concat ["%#{params.search_query}%"] * text_columns.size
    end
    [sql].concat vars
  end
  
  def sql_select_statement
    "DISTINCT #{table_name}.*"
  end
  
  def sql_order_statement
    "#{table_name}.#{active_column.sql_column_name_and_order}"
  end
  
  def prepare_columns
    figure_out_columns_if_none_are_given
    mark_active_column
    @columns
  end

  def figure_out_columns_if_none_are_given
    if @columns.blank?
      @columns = names_to_columns( @klass.content_columns.map(&:name) )
    end
  end
  
  def mark_active_column
    candidate = @columns.first
    if params.sort_by_field
      candidate = @columns.find { |col| col.to_s == params.sort_by_field }
    end
    if params.sort_order
      candidate.sort_order = params.sort_order
    end
    candidate.active!
  end
  
  def active_column
    columns.find(&:active?)
  end
  
  def table_name
    @klass.to_s.tableize
  end
  
  def with_scope(conditions, &block)
    @klass.send(:with_scope, :find => { :conditions => conditions}, &block)
  end
  
  def text_columns
    columns.find_all(&:text?)
  end
  
  def names_to_columns(names)
    names.map { |name| Column.new(name) } 
  end
  
  def renderer
    @_renderer ||= ColumnRenderer.new(params, controller)
  end
  
end