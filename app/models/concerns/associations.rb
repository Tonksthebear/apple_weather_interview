module Associations
  extend ActiveSupport::Concern

  included do
    class_attribute :relationships
    self.relationships = { has_many: {}, has_one: {}, belongs_to: {} }

    def loaded_relationships
      @loaded_relationships ||= { has_many: {}, has_one: {}, belongs_to: {} }
    end
  end

  class_methods do
    def has_many(relationship_name, options = {})
      self.relationships[:has_many][relationship_name] = options

      define_method(relationship_name) do |options = {}|
        loaded_relationships[:has_many][relationship_name]
      end

      define_method("#{relationship_name}=") do |options|
        raise ArgumentError, "Invalid argument type" unless options.is_a?(Array)
        related_class = relationship_name.to_s.singularize.camelize.constantize

        loaded_relationships[:has_many][relationship_name] = options.map do |option|
          if option.is_a?(Hash)
            related_class = relationship_name.to_s.singularize.camelize.constantize
            related_class.from_json(**option)
          elsif option.is_a?(related_class)
            option
          else
            raise ArgumentError, "Invalid argument type"
          end
        end
      end

      if options[:param_name]
        alias_method "#{options[:param_name]}=", "#{relationship_name}="
      end
    end

    def has_one(relationship_name, options = {})
      define_method(relationship_name) do
        loaded_relationships[:has_one][relationship_name] ||= begin
          related_class = relationship_name.to_s.camelize.constantize
          find_by_parameters = { "#{relationship_name}_id" => id }
          if default_scope = options[:default_scope]
            find_by_parameters = default_scope.to_h do |attr_name|
              [ attr_name, self.send(attr_name) ]
            end
          end
          item = related_class.find_by(**find_by_parameters)
          item.send("#{self.class.name.downcase}_id=", self.id) if item
          item
        end
      end

      define_method("#{relationship_name}=") do |option|
        related_class = relationship_name.to_s.camelize.constantize

        loaded_relationships[:has_one][relationship_name] = if option.is_a?(Hash)
            related_class = relationship_name.to_s.singularize.camelize.constantize
            related_class.from_json(**option)
        elsif option.is_a?(related_class)
            option
        else
            raise ArgumentError, "Invalid argument type"
        end
      end
    end

    def belongs_to(relationship_name, options = {})
      attr_accessor "#{relationship_name}_id"

      define_method(relationship_name) do |options|
        loaded_relationships[:belongs_to][relationship_name] ||= begin
          related_class = relationship_name.to_s.singularize.camelize.constantize
          related_class.find(self.send("#{relationship_name}_id"))
        end
      end

      define_method("#{relationship_name}=") do |options|
        related_class = relationship_name.to_s.camelize.constantize

        loaded_relationships[:belongs_to][relationship_name] = if options.is_a?(Hash)
              related_class = relationship_name.to_s.singularize.camelize.constantize
              item = related_class.from_json(**option)
              self.send("#{relationship_name}_id=", item&.id)
        elsif options.is_a?(related_class)
              self.send("#{relationship_name}_id=", option.id)
              option
        else
              raise ArgumentError, "Invalid argument type"
        end
      end
    end

    def has_relationship_by_name(name)
      relationships[:has_many].key?(name) ||
      relationships[:has_one].key?(name) ||
      relationships[:belongs_to].key?(name)
    end
  end
end
