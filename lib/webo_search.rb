require "webo_search/engine"
# require "webo_search/configuration"

module WeboSearch
  class << self
    attr_accessor :configuration
  end

  def self.results(params)
    begin
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
    rescue Excepption => e
      Rails.logger.info("Error from search engine : #{e.message}")
      []
    end
  end

  def self.build_params(params, record_details)
    conditions = []
    params.each do |key, values|
      r_details = record_details.select{ |tn| tn[1] == key }
      record_detail = r_details.empty? ? record_details.select{ |tn| tn[1].include?(key) }.first : r_details.first
      values.each do |k, v|
        conditions << build_query_string(k, v, record_detail) if v.present?
      end
    end
    conditions.join(' AND ')
  end

  def self.build_query_string(field_name, value, record_detail)
    if field_name.include?('_OR_')
      or_query = []
      field_names = field_name.split('_OR_')
      field_names.each do |field_name|
        value.split(' ').each do |v|
          or_query << query_string(field_name, v, record_detail)
        end
      end
      or_query.join(' OR ').prepend('(') + ')'
    else
      query_string(field_name, value, record_detail)
    end
  end

  def self.query_string(field_name, value, record_detail)
    if Object.const_get(record_detail[0]).columns_hash["#{field_name}"].type == :string
      "#{record_detail[1]}.#{field_name} Ilike '%#{value}'"
    else
       "#{record_detail[1]}.#{field_name} = #{value}"
    end
  end

  def self.configure
    YAML.load_file("#{Rails.root}/config/webo_search.yml")
  end
end
