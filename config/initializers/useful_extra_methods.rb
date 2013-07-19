WillPaginate::Collection.class_eval do  alias :to_json_without_paginate
:to_json
def to_json(options = {})
  { :current_page => current_page,
    :per_page => per_page,
    :total_entries => total_entries,
    :total_pages => total_pages,
    :items => to_a
  }.to_json(options)
end
end
WillPaginate::ViewHelpers.pagination_options[:prev_label] = '← Prev'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next →'

if RUBY_VERSION < "1.8.7"
require 'enumerator'
  module Enumerable
    alias_method :original_each_slice, :each_slice
    def each_slice(count, &block)
      if block_given?
        # call original method when used with block
        original_each_slice(count, &block)
      else
        # no block -> emulate
        self.enum_for(:original_each_slice, count)
      end
    end
  end
end

class Array
  def add_condition(condition, conjunction='and')
    if condition.is_a? Array
      if self.empty?
        (self << condition).flatten!
      else
        self[0] += " #{conjunction} " + condition.shift
        (self << condition).flatten!
      end
    elsif condition.is_a? String
      self[0] += " #{conjunction} " + condition
    else
      raise "don't know how to handle this condition type"
    end
    self
  end
end
