class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  has_many :accessibilities, :dependent => :destroy
  has_many :notes, :through => :accessibilities

  has_one :owning_note, :class_name => "Note",
                        :foreign_key => "owner_group_id"
  belongs_to :backend, :polymorphic => true
end
