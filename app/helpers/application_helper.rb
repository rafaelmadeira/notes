module ApplicationHelper
  def sort_column
    %w[created_at updated_at].include?(params[:sort]) ? params[:sort] : 'created_at'
  end
end
