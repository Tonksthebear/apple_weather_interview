class Geocode < BaseResource
  BASE_URL = "https://geocoding-api.open-meteo.com/v1/"

  attribute :id, :integer
  attribute :name, :string
  attribute :latitude, :float
  attribute :longitude, :float
  attribute :elevation, :float
  attribute :feature_code, :string
  attribute :country_code, :string
  attribute :population, :integer
  attribute :postcodes, default: []
  attribute :country_id, :integer
  attribute :country, :string
  attribute :admin1, :string
  attribute :admin2, :string
  attribute :admin3, :string
  attribute :admin4, :string
  attribute :cache_missed, :boolean

  has_one :forecast, default_scope: [ :latitude, :longitude ]

  # Enable Rails to implicitly route to instance
  def persisted?
    id.present?
  end

  class << self
    def find(id)
      raise ArgumentError, "ID cannot be blank" if id.blank?

      cache_missed = false

      # We are only building a cache key for the ID because cache_key_with_version depends on an updated_at timestamp
      geocode = Rails.cache.fetch("geocode/#{id}", expires_in: 30.minutes) do
        cache_missed = true
        get("get", id:)
      end

      geocode.cache_missed = cache_missed
      geocode
    end

    def where(name:)
      raise ArgumentError, "Name cannot be blank" if name.blank?
      Array.wrap(get("search", name:, country_code: "US")).select(&:persisted?)
    end

    private

    def transform_key(key)
      key.to_s.camelcase(:lower)
    end
  end
end
