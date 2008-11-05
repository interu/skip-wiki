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

  it "should create a new instance given valid attributes" do
    Page.create!(@valid_attributes)
  end

  it "should raise error if :format_type is'nt hiki nor html" do
    lambda{
      Page.create!(@valid_attributes.merge(:format_type=>"hoge"))
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  describe "#label_indexings = [{:label_index_id=>1}]" do
    before do
      @page = Page.new(@valid_attributes)
      @label = LabelIndex.create(:note=>mock_model(Note), :name=>"foobar")
      @page.label_index_ids = [@label.id]
    end

    it "should be new_record" do
      @page.should be_new_record
    end

    it "#label_index_ids.should == [@label.id]" do
      @page.label_index_ids.should == [@label.id]
    end

    it "save! then should have 1 label_indexings" do
      @page.save!
      @page.should have(1).label_indexings
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

  describe ".fulltext('keyword')" do
    before do
      History.should_receive(:find_all_by_head_content).
        with('keyword').
        and_return( [@history = mock_model(History)] )
    end

    it ".options.should == {:conditions => ['histories.id IN (?)', @history.id], :include => :histories}" do
      Page.fulltext("keyword").proxy_options.should ==
        {:conditions => ["#{History.quoted_table_name}.id IN (?)", [@history.id]], :include => :histories}
    end
  end

  describe "fulltext()で実際に検索する場合" do
    before do
      @page = Page.create!(@valid_attributes)
      History.create(:content => Content.new(:data => "the keyword"),
                     :versionable => @page,
                     :user => mock_model(User),
                     :revision => History.count.succ)
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
  end
end

