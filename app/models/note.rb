class Note < ActiveRecord::Base
  PUBLICITY_READABLE = 0
  PUBLICITY_WRITABLE = 1
  PUBLICITY_MEMBER_ONLY = 2

  PUBLIC_CONDITION = ["#{table_name}.publicity IN (:publicity)",
                      {:publicity => [PUBLICITY_READABLE, PUBLICITY_WRITABLE]} ].freeze

  WIZARD_STEPS = [ N_("Select group"), N_("Select category"), N_("Select publicity"),
                   N_("Select label navigation style"), N_("Input name"), N_("Input description"),
                   N_("Select list attachments"), N_("Confirm") ].freeze

  has_friendly_id :name

  validates_presence_of :owner_group, :name, :display_name, :description
  validates_uniqueness_of :name
  validates_inclusion_of :publicity, :in => (PUBLICITY_READABLE..PUBLICITY_MEMBER_ONLY)

  belongs_to :owner_group, :class_name => "Group"
  belongs_to :category

  has_many :accessibilities
  has_many :label_indices
  has_many :pages, :dependent => :delete_all do
    def add(attrs, user)
      returning(build) do |page|
        page.edit(attrs[:content], user)
        page.attributes = attrs.except(:content)
        page.label_index_id ||= proxy_owner.default_label.id
      end
    end
  end

  has_many :attachments, :as => :attachable

  named_scope :free, {:conditions=>PUBLIC_CONDITION}

  named_scope :recent, proc{|*args|
    {
     :order => "#{table_name}.updated_at DESC",
     :limit => args.shift || 10 # default
    }
  }

  named_scope :fulltext, proc{|word|
    return {} if word.blank?
    t = quoted_table_name
    w = "%#{word}%"
    {:conditions => ["#{t}.display_name LIKE ? OR #{t}.description LIKE ?", w, w]}
  }

  attr_writer :group_backend_type
  attr_accessor :group_backend_id

  def group_backend_type
    @group_backend_type || owner_group.backend_type
  end

  def groups=(groups)
    accessibilities.replace groups.map{|g| accessibilities.build(:group=>g) }
  end

  def groups
    accessibilities.map(&:group)
  end

  def public_writable?
    Note::PUBLICITY_WRITABLE == publicity
  end

  def public_readable?
    [Note::PUBLICITY_READABLE, Note::PUBLICITY_WRITABLE].include?(publicity)
  end

  def to_param
    name_changed? ? name_was : name
  end

  def default_label
    label_indices.detect(&:default_label)
  end
end
