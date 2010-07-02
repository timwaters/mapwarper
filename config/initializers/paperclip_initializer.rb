# class Document < ActiveRecord::Base
#
# has_attached_file :document, :styles => { :medium => "300x300>" }
#
# before_save :save_dimensions
#
# def save_dimensions
#
# self.width = document.width
# self.height = document.height
#
# end
#
# end

module Paperclip
  class Attachment
    def width(style = default_style)
      Paperclip::Geometry.from_file(to_file(style)).width
    end

    def height(style = default_style)
      Paperclip::Geometry.from_file(to_file(style)).height
    end

    def image?(style = default_style)
      to_file(style).image?
    end
  end

 
end