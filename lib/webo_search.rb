require "webo_search/engine"
# require "webo_search/configuration"

module WeboSearch
  class << self
    attr_accessor :configuration
  end

  def self.results(params)
      search_configuration = WeboSearch.configure
      if params[:namespace].present? && search_configuration.has_key?(params[:namespace])
        search_configuration['primary_model'] = search_configuration["#{params[:namespace]}"]['primary_model']
        search_configuration['associated_model'] = search_configuration["#{params[:namespace]}"]['associated_model']
      end
      primary_model_name = search_configuration['primary_model']['class_name']  || search_configuration['primary_model'].keys.first.capitalize
      record_details =  Object.const_get(primary_model_name).reflect_on_all_associations.map{|r| [r.class_name,r.table_name]}
      record_details.push([primary_model_name,Object.const_get(primary_model_name).table_name])

      if search_configuration['associated_model'].present?
        associated_model_names = search_configuration['associated_model'].keys rescue []
        associated_model_names = Object.const_get(primary_model_name).reflect_on_all_associations.map(&:name).select{| model_name | associated_model_names.include?(model_name.to_s)}

        Object.const_get(primary_model_name).joins(*associated_model_names).where(build_params(params[:search], record_details))
      else
         Object.const_get(primary_model_name).where(build_params(params[:search], record_details))
      end
  end

  def self.build_params(params, record_details)
    conditions = []
    values_array = []
    params.each do |key, values|
      r_details = record_details.select{ |tn| tn[1] == key }
      record_detail = r_details.empty? ? record_details.select{ |tn| tn[1].include?(key) }.first : r_details.first
      values.each do |k, v|
        if v.present? && v.to_s != 'Ignore'
          query_details = build_query_string(k, v, record_detail)
          conditions << query_details[:query]
          values_array.concat(query_details[:value])
        end
      end
    end
    conditions = conditions.join(' AND ')
    values_array.unshift(conditions)
  end

  def self.build_query_string(field_name, value, record_detail)
    if field_name.include?('_OR_')
      or_query = []
      field_names = field_name.split('_OR_')
      values_array = []
      field_names.each do |field_name|
        value.split(' ').each do |v|
          query_details = query_string(field_name, v, record_detail)
          or_query << query_details[:query]
          values_array.push(query_details[:value])
        end
      end
      or_query = or_query.join(' OR ').prepend('(') + ')'
      {query: or_query, value: values_array.flatten}
    else
      query_string(field_name, value, record_detail)
    end
  end

  def self.query_string(field_name, value, record_detail)
    if Object.const_get(record_detail[0]).columns_hash["#{field_name}"].type == :string
      value = "#{value}%"
      query = "#{record_detail[1]}.#{field_name} ILIKE ?"
    else
       query = "#{record_detail[1]}.#{field_name} = ?"
    end
    {query: query, value: [value]}
  end

  def self.configure
    YAML.load_file("#{Rails.root}/config/webo_search.yml")
  end
end
