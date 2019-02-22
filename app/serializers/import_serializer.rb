class ImportSerializer < ActiveModel::Serializer
  attributes :name, :status, :created_at, :finished_at, :updated_at
  attribute :file_count, :if => :status_is_ready?
  has_many :maps
  belongs_to :user
  
  def status_is_ready?
    object.status == :ready && !instance_options[:index]
  end
  
  link(:self) { api_v1_import_url(object.id) }
  
end
