# -*- encoding : utf-8 -*-
module Dao
  module Validations
    class Error < Dao::Error
      attr_accessor :errors

      def initialize(*args, &block)
        @errors = args.shift if args.first.respond_to?(:full_messages)
        super(*args, &block)
      end

      def object
        @errors.object if(@errors and @errors.respond_to?(:object))
      end
    end

    Dao.load('validations/callback.rb')
    Dao.load('validations/common.rb')
    Dao.load('validations/validator.rb')

    ClassMethods = proc do
      def validator
        @validator ||= Validator.mixin(self)
      end

      def validator=(validator)
        @validator = validator
      end

      %w(
        validations
        validates
        validates_each
      ).each do |method|
        module_eval <<-__, __FILE__, __LINE__
          def self.#{ method }(*args, &block)
            validator.#{ method }(*args, &block)
          end
        __
      end
    end

    InstanceMethods = proc do
      def validator
        @validator ||= Validator.mixin(self)
      end

      def validator=(validator)
        @validator = validator
      end

      %w(
        validations
        validates
        validates_each
        validated?
        validated!
        validate
        validate!
        run_validations
        run_validations!
        valid!
        valid?
        forcing_validity?
        errors
      ).each do |method|
        module_eval <<-__, __FILE__, __LINE__
          def #{ method }(*args, &block)
            validator.#{ method }(*args, &block)
          end
        __
      end
    end

    def Validations.included(other)
      other.send(:instance_eval, &ClassMethods)
      other.send(:class_eval, &InstanceMethods)
      other.send(:include, Common)
      other.send(:extend, Common)
      super
    end

  end

  Dao.load('validations/instance.rb')
end
