# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  describe "User validation" do
    before do
      @it = User.new(:name => "", :display_name => "")
      @it.valid? && flunk("前提条件の間違い")
    end

    it{ @it.should have_at_least(1).errors_on(:name) }
    it{ @it.should have_at_least(1).errors_on(:display_name) }
  end

  describe "#build_note" do
    before do
      Page.stub!(:front_page_content).and_return("---FrontPage---")
      @user = create_user
      @note = @user.build_note(
        :name => "value for name",
        :display_name => "value for display_name",
        :description => "value for note description",
        :publicity => 0,
        :category_id => "1",
        :group_backend_type => "BuiltinGroup",
        :group_backend_id => ""
      )
    end

    describe "(with SQL injection group)" do
      before do
        @note = @user.build_note(
          :name => "value for name",
          :display_name => "value for display_name",
          :publicity => 0,
          :category_id => "1",
          :group_backend_type => "; DELETE * FROM users"
        )
      end

      it "the note should not be valid" do
        @note.should_not be_valid
      end
    end

    describe "#memberships.replace_by_type" do
      fixtures :users
      before do
        @user = create_user(:name=>"alice")
        [
          @skip1 = SkipGroup.create!(:name=>"skip1",:gid=>"skip1"),
          @skip2 = SkipGroup.create!(:name=>"skip2",:gid=>"skip2"),
          @builtin = BuiltinGroup.create!,
        ].each do |backend|
          group = Group.new(:name=>"#{backend.class}_#{backend.id}", :backend=>backend)
          @user.memberships.build(:group => group)
        end

        @user.save!
      end

      describe "BuiltinGroup" do
        before do
          @another = BuiltinGroup.create!
          @user.memberships.replace_by_type(BuiltinGroup, Group.new(:name=>"another", :backend=>@another))
        end
        it "との関連を変更できること" do
          @user.memberships.map{|m| m.group.backend }.should == [@skip1, @skip2, @another]
        end
      end

      describe "SkipGroup" do
        before do
          @another = SkipGroup.create!(:name=>"name", :display_name=>"display_name", :gid=>"hoge")
          @user.memberships.replace_by_type(SkipGroup, Group.new(:name=>"another", :backend=>@another))
        end
        it "との関連を変更できること" do
          @user.memberships.map{|m| m.group.backend }.should == [@builtin, @another]
        end
      end
    end
  end

  describe "#admin?" do
    describe "管理者ではない場合" do
      before { @user = create_user(:admin=>"0") }
      it "falseが返却されること" do
        @user.admin?.should be_false
      end
    end
    describe "管理者の場合" do
      before { @user = create_user(:admin=>"1") }
      it "trueが返却されること" do
        @user.admin?.should be_true
      end
    end
  end

  describe ".fulltext" do
    it "'quen'で検索すると1件該当すること" do
      User.fulltext("quen").should have(1).items
    end

    it "'--none--'で検索すると0件該当すること" do
      User.fulltext("--none--").should have(0).items
    end

    it "(nil)で検索すると3件該当すること" do
      User.fulltext(nil).should have(3).items
    end
  end
end
