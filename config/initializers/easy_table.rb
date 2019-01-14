# encoding: UTF-8
# frozen_string_literal: true

module EasyTable
  module Components
    module Columns
      def column(title, label_or_opts = nil, opts = {}, &block)
        if @options[:model]
          label_or_opts ||= {}
          label_or_opts.merge!({model: @options[:model]})
        end
        if @options[:scope]
          label_or_opts ||= {}
          label_or_opts.merge!({scope: @options[:scope]})
        end
        if label_or_opts.is_a?(Hash) && label_or_opts.extractable_options?
          label = nil
          opts = label_or_opts
        else
          label = label_or_opts
          opts = opts
        end
        child = node << Tree::TreeNode.new(title)
        column = Column.new(child, title, label, opts, @template, block)
        child.content = column
      end
    end

    module Base
      def translate(key)
        if @opts[:model]
          @opts[:model].human_attribute_name(@title)
        elsif @opts[:scope]
          I18n.t("easy_table.#{@opts[:scope]}.#{@title}")
        else
          controller = @template.controller_name
          I18n.t("easy_table.#{controller.singularize}.#{key}", default: key.to_s)
        end
      end
    end
  end
end
