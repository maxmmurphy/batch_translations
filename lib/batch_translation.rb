module ActionView
  module Helpers
    class FormBuilder
      def globalize_fields_for(locale, *args, &proc)
        raise ArgumentError, "Missing block" unless block_given?
        @index = @index ? @index + 1 : 1
        object_name = "[translations_attributes][#{@index}]"
        object = @object.translations.find_by_locale locale.to_s 
        @template.concat @template.hidden_field_tag("#{@object.class.name.downcase}[#{object_name}][locale]", locale)
        @template.concat @template.hidden_field_tag("#{@object.class.name.downcase}[#{object_name}][id]", object.id) unless object.nil?
        tt = fields_for(object_name, object, *args, &proc)
        @template.concat tt
        @template
      end
    end
  end
end

module Globalize
  module Model
    module ActiveRecord
      module Translated
        module Callbacks
          def enable_nested_attributes
            accepts_nested_attributes_for :translations
          end
        end
        module InstanceMethods
          def after_save
            init_translations
          end
          # Builds an empty translation for each available 
          # locale not in use after creation
          def init_translations
            I18n.translated_locales.reject{|key| key == :root }.each do |locale|
              translation = self.translations.find_by_locale locale.to_s
              if translation.nil?
                translations.build :locale => locale
                save
              end
            end
          end
        end
      end
    end
  end
end