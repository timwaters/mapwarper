class Annotation < ActiveRecord::Base
  belongs_to :map
  belongs_to :user
  validates_presence_of :geom
  validates_presence_of :body

  include PgSearch
  pg_search_scope :body_search, :against => :body, :using => {
    :tsearch => {:prefix => true,
      highlight: {
        StartSel: '<b>',
        StopSel: '</b>',
        ShortWord: 3,
        MaxWords: 20,
        MinWords: 1,
        HighlightAll: true,
        MaxFragments: 4,
        FragmentDelimiter: '&hellip;'
      }}
  }

  def center
    if defined? geom.centroid
      {:lat => geom.centroid.y, :lon => geom.centroid.x}
    elsif geom && geom.geometry_type == RGeo::Feature::Point
      {:lat => geom.y, :lon => geom.x}
    else
      nil
    end
  end
  
  def center_lat
    if center
      center[:lat]
    end
  end

  def center_lon
    if center
      center[:lon]
    end
  end
 
  
end
