class CleverReportsController < ApplicationController
  
  layout "crm/application"
  
  user_only :edit, :create, :destroy, :index, :new, :show, :update
  
  before_filter :get_report, :except => %w{create index new}
  
  def index
    @reports = CleverReport.all
  end
  
  def show

  end
  
  def new
    @report = CleverReport.new
  end
  
  def create
    @report = CleverReport.new(params[:clever_report])
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
    if @report.update_attributes(params[:clever_report])
      if @report.last_step?
        flash[:notice] = "Finished."
        return redirect_to(@report)
      end
      @report.step_num += 1
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
