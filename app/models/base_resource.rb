class BaseResource
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Associations
  BASE_URL = "https://api.open-meteo.com/v1/"

  class << self
    def get(endpoint, **kwargs)
      request(:get, endpoint, kwargs)
    end

    def request(method, endpoint, params = {})
      url = "#{self::BASE_URL}#{endpoint}"
      options = { query: params.deep_transform_keys! { |key| transform_key(key) } }
      response = HTTParty.send(method, url, options)
      if response.success?
        if response.parsed_response["results"].is_a?(Array)
          response.parsed_response["results"].map { |item| from_json(item) }
        else
          from_json(response.parsed_response)
        end
      else
        raise StandardError, "Error: #{response.code} - #{response.message}"
      end
    end

    def from_json(json)
      attributes = {}
      json.each do |key, value|
        # Convert camelCase to snake_case
        attr_name = key.underscore
        # Check if the attribute or relationship is defined
        if attribute_types.key?(attr_name)
          attributes[attr_name] = value
        elsif has_relationship_by_name(attr_name)
          attributes[attr_name] = value
        else
          # Ignore unknown attributes
          next
        end
      end

      new(attributes)
    end

    private

    def transform_key(key)
      key.to_s
    end
  end
end
