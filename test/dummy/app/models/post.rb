class Post
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :author
  attribute :avatar, :string
  attribute :name, :string
  attribute :published, :boolean, default: -> { false }
end
