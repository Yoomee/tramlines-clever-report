class CleverReportsController < ApplicationController
  
  admin_only :edit, :create, :destroy, :index, :new, :show, :update
  
  before_filter :get_report, :except => %w{create index new}
  
  def index
    @reports = CleverReport.descend_by_created_at.paginate(:page => params[:page], :per_page => 20)
  end
  
  def show
    @report.update_attributes(:last_run_at => Time.now, :last_run_by => logged_in_member)
    @results = @report.results.paginate(:page => params[:page], :per_page => 20)
  end
  
  def new
    @report = CleverReport.new
  end
  
  def create
    @report = CleverReport.new(params[:clever_report].merge(:member => logged_in_member))
    if @report.save
      if @report.last_step?
        flash[:notice] = "Finished."
        return redirect_to(@report)
      end
      @report.step_num += 1
    end
    render :action => 'new'
  end

  def edit
  end
  
  def update
    if @report.update_attributes(params[:clever_report].merge(:last_edited_at => Time.now, :last_edited_by => logged_in_member))
      if @report.last_step?
        flash[:notice] = "Finished."
        return redirect_to(@report)
      end
      @report.step_num += 1
      @report.filters.build if @report.last_step? && @report.filters.empty?
    end
    render :action => 'edit'
  end
  
  def destroy
    @report.destroy
    flash[:notice] = "Successfully deleted report."
    redirect_to reports_url
  end
  
  private
  def get_report
    @report = CleverReport.find(params[:id])
  end
  
end
