module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module ApiObjects
          class ResourceIdentifier
            def initialize(serializer, association = nil)
              @id = id_for(serializer, association)
              @type = type_for(serializer, association)
            end

            def as_json
              { id: id, type: type }
            end

            protected

            attr_reader :id, :type

            private

            def formatted_type(type)
              type = if ActiveModel::Serializer.config.jsonapi_resource_type == :singular
                       type.singularize
                     else
                       type.pluralize
                     end
              type.underscore
            end

            def type_for(serializer, association = nil)
              if association
                if association.serializer.respond_to?(:type)
                  formatted_type(association.serializer.type)
                elsif serializer.object.class.respond_to?(:reflections)
                  reflection = serializer.object.class.reflections[association.key.to_s]
                  formatted_type(reflection.class_name)
                else
                  type_for(association.serializer)
                end
              else
                return serializer._type if serializer._type
                if ActiveModelSerializers.config.jsonapi_resource_type == :singular
                  serializer.object.class.model_name.singular
                else
                  serializer.object.class.model_name.plural
                end
              end
            end

            def id_for(serializer, association = nil)
              if association
                if serializer.respond_to?("#{association.key}_id")
                  serializer.send("#{association.key}_id")
                else
                  id_for(association.serializer)
                end
              else
                serializer.read_attribute_for_serialization(:id).to_s
              end
            end
          end
        end
      end
    end
  end
end
