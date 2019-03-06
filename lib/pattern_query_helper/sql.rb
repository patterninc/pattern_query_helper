module PatternQueryHelper
  class Sql
    def self.sql_query(config)
      model = config[:model]
      query = config[:query]
      query_params = config[:query_params] || {}
      page = config[:page]
      per_page = config[:per_page]
      filter_string = config[:filter_string]
      filter_params = config[:filter_params] || {}
      sort_string = config[:sort_string]

      if page && per_page
        query_params[:limit] = per_page
        query_params[:offset] = (page - 1) * per_page
        limit = "limit :limit offset :offset"
      end

      query_params = query_params.merge(filter_params).symbolize_keys
      sort_string = "order by #{sort_string}" if !sort_string.blank?
      filter_string = "where #{filter_string}" if !filter_string.blank?

      sql = %(
          with query as (#{query})
          select *
          from query
          #{filter_string}
          #{sort_string}
          #{limit}
        )

      model.find_by_sql([sql, query_params])
    end

    def self.sql_query_count(config)
      model = config[:model]
      query = config[:query]
      query_params = config[:query_params] || {}
      filter_string = config[:filter_string]
      filter_params = config[:filter_params] || {}

      query_params = query_params.merge(filter_params).symbolize_keys
      filter_string = "where #{filter_string}" if !filter_string.blank?

      count_sql = %(
          with query as (#{query})
          select count(*) as count
          from query
          #{filter_string}
        )

      model.find_by_sql([count_sql, query_params]).first["count"]
    end

    def self.single_record_query(config)
      results = sql_query(config)
      results.first
    end

    def self.parse_result_columns(query)
      selects = query.split(/[Ss][Ee][Ll][Ee][Cc][Tt]/).last.split(/[Ff][Rr][Oo][Mm]/).first.split(",")
      selects = selects.map{ |c| c.strip}
      columns = {}
      selects.each do |s|
        alias_split = s.split(/ [Aa][Ss] /)
        table_column_split = s.split(".")
        if alias_split.length == 2
          sql_alias = alias_split.last.strip
          sql = alias_split.first.strip
        elsif table_column_split.length == 2
          sql_alias = table_column_split.last.strip
          sql = s
        else
          puts "failed to parse column alias from the following sql select clause '#{s}'"
        end
        columns["#{sql_alias}"] = sql if sql_alias
      end
      columns
    end

  end
end
