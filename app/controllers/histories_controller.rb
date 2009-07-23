class HistoriesController < ApplicationController
  layout "pages"
  include IframeUploader
  include PagesModule::PagesUtil

  def index
    @page = history_accessible_pages.find(params[:page_id])
    @histories = @page.histories
  end

  def show
    @page = history_accessible_pages.find(params[:page_id])
    @history = @page.histories.detect{|h| h.id == params[:id].to_i }
  end

  def diff
    @page = history_accessible_pages.find(params[:page_id], :include => :histories)
    @diffs = @page.diff(params[:from], params[:to])
  end

  def new
    @page = history_accessible_pages.find(params[:page_id])
  end

  def create
    @page = history_accessible_pages.find(params[:page_id])
    @history = @page.edit(params[:history][:content], current_user)
    if @history.save
      respond_to do |format|
        format.html{ redirect_to note_page_url(current_note, @page) }
        format.js{ head(:created, :location => note_page_history_path(current_note, @page, @history)) }
      end
    else
      errors = [@history, @history.content].map{|m| m.errors.full_messages }.flatten
      respond_to do |format|
        format.js{ render(:json => errors, :status=>:unprocessable_entity) }
      end
    end
  end

  def update
    @page = history_accessible_pages.find(params[:page_id])
    @history = @page.histories.find(params[:id], :include=>:content)
    if @history.content.data != params[:history][:content]
      @history.content.data = params[:history][:content]
      ActiveRecord::Base.transaction do
        @history.content.save!
        @history.update_attributes!(:user => current_user, :updated_at => Time.now.utc)
      end
    end
    respond_to do |format|
      format.js{ head(:ok) }
    end
  end

  private
  def history_accessible_pages
    current_user.page_editable?(current_note) ? current_note.pages.active : current_note.pages.active.published
  end
end

