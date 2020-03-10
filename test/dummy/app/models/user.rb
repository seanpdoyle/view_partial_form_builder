class User
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
end
