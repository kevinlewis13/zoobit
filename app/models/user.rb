class User < ActiveRecord::Base
  include Gravtastic
  gravtastic
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :omniauthable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :pets
  has_many :friendships
  delegate :dogs, :cats, :birds, :rabbits, to: :pets
  validates :username, presence: true, :uniqueness => {:case_sensitive => false}
  # Virtual field representing whether user is logged in.
  attr_accessor :login

  #Below method taken from:
  #https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  #Below methods for omniauth are from
  #https://gist.github.com/ivanoats/7076128
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :id)).first_or_create do |user|
      user.provider = auth.provider
      user.id = auth.uid
      user.username = auth.info.nickname.nil? ? auth.info.name : auth.info.nickname
      user.email = auth.info.email.nil? ? "#{user.username}-TEMPORARY@zoobit.net" : auth.info.email
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def earn_points
    self.points += 10
    self.save
    self.pet_slots = 5 if self.points >= 2000 && self.pet_slots < 5
    self.pet_slots = 4 if self.points >= 750 && self.pet_slots < 4
    self.pet_slots = 3 if self.points >= 300 && self.pet_slots < 3
    self.pet_slots = 2 if self.points >= 100 && self.pet_slots < 2
    self.save
  end

  def self.search(query)
    where("username like ?", "%#{query}%")
  end

end
