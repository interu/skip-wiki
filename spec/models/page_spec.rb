require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Page do
  describe "deafult values" do
    it ".format_type.should == 'html'" do
      Page.new.format_type.should == 'html'
    end
  end

  before(:each) do
    @valid_attributes = {
      :note_id => "1",
      :last_modied_user_id => "1",
      :name => "value for name",
      :display_name => "value for display_name",
      :format_type => "hiki",
      :published_at => Time.now,
      :deleted_at => Time.now,
      :lock_version => "1"
    }
  end

  describe "#label_index_id = an_label.id" do
    before do
      @note = mock_model(Note)
      @page = Page.new(@valid_attributes.merge(:note=>@note))
      @label = LabelIndex.create(:note=>@note, :display_name=>"foobar")

      @page.label_index_id = @label.id
    end

    it "should be new_record" do
      @page.should be_new_record
    end

    it "#label_index_id.should == @label.id" do
      @page.label_index_id.should == @label.id
    end

    describe "save!" do
      before do
        @note.stub!(:label_indices).and_return(LabelIndex)
        @page.edit("content", mock_model(User))
        @page.save!
      end

      it "then should have 1 label_indexings" do
        @page.reload.label_index.should_not be_nil
      end

      it "#label_index_id.should_not be nil" do
        Page.find(@page).label_index_id.should_not be_nil
      end

      it "#label_indexings.firstのpage_orderは1であること" do
        l, = Page.find(@page).label_indexings
        l.page_order.should == 1
      end

      describe "別のページを追加した場合" do
        before do
          @another = Page.new(@page.attributes) do |page|
            page.note = @note
            page.name = "another"
            page.label_index_id = @label.id
          end
          @another.edit("content", mock_model(User))
          @another.save!
        end

        it "#label_indexings.firstのpage_orderは2であること" do
          l, = Page.find(@another).label_indexings
          l.page_order.should == 2
        end
      end
    end
  end

  describe "edit(content, user)" do
    before do
      @page = Page.new(@valid_attributes)
      @page.edit("hogehogehoge", mock_model(User))
    end

    it "Historyを作ること" do
      lambda{@page.save!}.should change(History,:count).by(1)
    end

    it "保存後のrevisionは1であること" do
      @page.save!; @page.reload
      @page.revision.should == 1
    end

    it "最新のコンテンツは'hogehogehoge'であること" do
      @page.save!
      @page.content.should == "hogehogehoge"
    end

    it "未保存でも最新のコンテンツは'hogehogehoge'であること" do
      @page.content.should == "hogehogehoge"
    end

    it "未保存でも最新のコンテンツは'hogehogehoge'であること" do
      @page.content.should == "hogehogehoge"
    end

    describe "同じ内容で保存した場合" do
      before do
        @page.save!
      end

      it "Historyを追加しないこと" do
        lambda{
          @page.edit("hogehogehoge", mock_model(User))
          @page.save!
        }.should_not change(History,:count)
      end
    end

    describe "再編集した場合" do
      before do
        @page.save!
        @page.reload
        @page.edit("edit to revision 2", mock_model(User))
        @page.save!
      end

      it "contentは新しいものであること" do
        @page.reload.content.should == "edit to revision 2"
      end

      it "contentの引数でrevisionを指定できること" do
        @page.reload.content(1).should == "hogehogehoge"
      end
    end

    describe "入力されたnew_historyがvalidでない場合" do
      before do
        @page.new_history.stub!(:valid?).and_return(false)
      end

      it "Pageもvalidでないこと" do
        @page.should_not be_valid
      end

      it "new_historyにエラーがあること" do
        @page.valid?
        @page.should have(1).errors_on(:new_history)
      end
    end
  end

  describe "edit(content, user) FAIL" do
    before do
      @page = Page.new(@valid_attributes)
      @page.edit("", mock_model(User))
    end

    it "should not be valid" do
      @page.should_not be_valid
    end
  end

  describe ".fulltext('keyword')" do
    before do
      History.should_receive(:find_all_by_head_content).
        with('keyword').
        and_return( [@history = mock_model(History, :page_id => "10")] )
    end

    it ".options.should == {:conditions => ['pages.id IN (?)', @history.page_id]}" do
      Page.fulltext("keyword").proxy_options.should ==
        {:conditions => ["#{Page.quoted_table_name}.id IN (?)", [@history.page_id]]}
    end
  end

  describe "fulltext()で実際に検索する場合" do
    before do
      @page = Page.new(@valid_attributes)
      @page.edit("the keyword", mock_model(User))
      @page.save!
    end

    it "結果は[@page]であること" do
      Page.fulltext("keyword").should == [@page]
    end
  end

  describe ".front_page" do
    before do
      @page = Page.front_page
    end
    it { @page.should be_new_record }
    it { @page.format_type.should == "html" }

    describe "は削除や識別子の変更ができないこと" do
      before do
        @page.edit("content", mock_model(User))
        @page.save!
      end

      it "識別子(name)を変更するとupdateできないこと" do
        @page.name = "notFrontPage"
        @page.should_not be_valid
      end

      it "FrontPageは削除できないこと" do
        lambda{ @page.destroy }.should_not change(Page, :count)
      end
    end
  end

  describe ".no_labels" do
    fixtures :notes, :pages

    it "notes(:our_note)は2つのラベルなしページがあること" do
      notes(:our_note).pages.no_labels.should have(2).items
    end

      it "order_in_labelを手動設定した場合、反映されること" do
        page = pages(:our_note_page_1)
        page.order_in_label = 1
        page.order_in_label.should == 1
      end

    describe "nth(n) で片方のupdated_atを新しくした場合" do
      before do
        @page = pages(:our_note_page_1)
        t = 5.days.since( @page.updated_at )
        Page.update_all("updated_at = '#{t.to_s(:db)}'", ["id = ?", @page.id])
      end

      it "nth(1)で更新されたページがとれること" do
        notes(:our_note).pages.no_labels.nth(1).should == [@page]
      end

      it "nth(2)で更新されないほうのページがとれること" do
        notes(:our_note).pages.no_labels.nth(2).should == [pages(:our_note_page_2)]
      end

      it "nth(3)では空配列がとれること" do
        notes(:our_note).pages.no_labels.nth(3).should == []
      end
    end
  end

  describe ".authored(*authors)" do
    fixtures :users
    before do
      @page = Page.new(@valid_attributes)
      @page.edit("hogehogehoge", users(:quentin))
      @page.save!

      another = Page.new(@valid_attributes)
      another.edit("foobar", users(:aaron))
      another.save!
    end

    it "authored('quentin') should == [@page]" do
      Page.authored("quentin").should == [@page]
    end

    it do
      Page.authored("quentin").fulltext("foobar").should == []
    end
  end

  describe ".labeled(*labels)" do
    fixtures :users, :notes, :pages
    before do
      @label = LabelIndex.create(:note=>notes(:our_note), :display_name=>"foobar")

      @page = pages(:our_note_page_1)
      @page.label_index_id = @label.id
      @page.edit("content", mock_model(User))
      @page.save!

      another_label = LabelIndex.create(:note=>notes(:our_note), :display_name=>"piyo")
      @another = pages(:our_note_page_2)
      @another.label_index_id = another_label.id
      @another.edit("another content", mock_model(User))
      @another.save!
    end

    it "labeled(@label) should == [@page]" do
      Page.labeled(@label.id).should == [@page]
    end

    it "labeled([]) should == [@page, @another]" do
      Page.labeled([]).should == [@page, @another]
      Page.labeled([]).labeled(@label.id).should == [@page]
    end

    it do
      Page.authored("quentin").fulltext("foobar").should == []
    end
  end
end

