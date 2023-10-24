class MailUserBookSerializer < ActiveModel::Serializer
  attributes :name

  has_many :authors do
    object.authors.pluck(:name).join(' ')
  end
end
