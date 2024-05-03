# frozen_string_literal: true

# Fixes deprecation and issue with:
#
## DEPRECATION WARNING: Passing the class as positional argument is deprecated and will be removed in Rails 7.2.
## Please pass the class as a keyword argument
#
# by dynamically providing type: and coder: if needed
#
# Globalize patch to remove warning in rails 7.1 about not providing :type in serialize
module Globalize
  module AttributeMethods
    module Serialization
      # Provides type by default depending on :coder and build serializer column
      def serialize(attr_name, class_name_or_coder = Object, **options)
        super(attr_name, **options)

        options = if class_name_or_coder == ::JSON
                    options.merge(coder: JSON, type: class_name_or_coder)
                  elsif %i[load dump].all? { |x| class_name_or_coder.respond_to?(x) }
                    options.merge(coder: class_name_or_coder, type: class_name_or_coder)
                  else
                    options.merge(coder: YAML, type: class_name_or_coder)
                  end


        coder = build_column_serializer(attr_name, options[:coder], options[:type], options[:yaml])

        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = coder
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
