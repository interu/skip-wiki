class PagesController < ApplicationController
  def index
    pages = accessible_pages
    pages = pages.fulltext(params[:keyword]) unless params[:keyword].blank?
    pages = pages.authored(*params[:authors].split(/\s*,\s*/)) unless params[:authors].blank?
    pages = pages.labeled(params[:label_index_id]) unless params[:label_index_id].blank?

    @pages = pages.scoped(page_order_white_list(params[:order])).find(:all)
  end

  def page_order_white_list(order, default = "#{Page.quoted_table_name}.updated_at DESC")
    {:order =>
      case order
      when "updated_at_DESC" then "#{Page.quoted_table_name}.updated_at DESC"
      when "updated_at_ASC"  then "#{Page.quoted_table_name}.updated_at ASC"
      else default
      end }
  end
  private :page_order_white_list

  def show
    @note = current_note
    @page = accessible_pages.find(params[:id], :include=>:note)
  end

  def new
    @page = current_note.pages.build
    @page.published_at ||= Time.now
    respond_to(:html)
  end

  def create
    @note = current_note
    begin
      ActiveRecord::Base.transaction do
        @page = @note.pages.add(params[:page], current_user)
        @page.save!
      end
      flash[:notice] = _("The page %{page} is successfully created") % {:page=>@page.display_name}
      respond_to do |format|
        format.html{ redirect_to note_page_path(@note, @page) }
      end
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html{ render :action => "new", :status => :unprocessable_entity }
      end
    end
  end

  def preview
    respond_to do |format|
      format.js do
        # FIXME
        render :text=>HikiDoc.to_xhtml(params[:page][:content], :level=>2), :type=>"text/html"
      end
    end
  end

  def edit
    @note = current_note
    @page = accessible_pages.find(params[:id])
    respond_to(:html)
  end

  def update
    @note = current_note
    begin
      ActiveRecord::Base.transaction do
        @page = accessible_pages.find(params[:id])
        @page.attributes = params[:page].except(:content)
        @page.save!
      end
      flash[:notice] = _("The page %{page} is successfully updated") % {:page=>@page.display_name}
      respond_to do |format|
        format.html{ redirect_to note_page_path(@note, @page) }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html{ render :action => "edit", :status => :unprocessable_entity }
      end
    end
  end

  private
  def accessible_pages(note = current_note, user = current_user)
    note.accessible?(user) ? note.pages : note.pages.published
  end
end
