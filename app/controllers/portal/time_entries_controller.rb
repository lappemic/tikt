module Portal
  class TimeEntriesController < BaseController
    def index
      @time_entries = current_client.time_entries.includes(:project, :subproject).recent

      if params[:start_date].present? && params[:end_date].present?
        @time_entries = @time_entries.for_date_range(params[:start_date], params[:end_date])
      end
    end
  end
end
