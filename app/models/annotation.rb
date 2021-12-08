class Annotation < ActiveRecord::Base
  belongs_to :map
  belongs_to :user

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

 
  
end
