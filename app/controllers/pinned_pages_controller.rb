class PinnedPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pinned_page, only: %i[destroy]

  def create
    @pinned_page = current_user.pinned_pages.find_or_initialize_by(page_url: params[:page_url])
    @pinned_page.title = params[:title]

    if @pinned_page.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'Page pinned successfully.' }
        format.turbo_stream do
          flash.now[:success] = 'Page pinned successfully.'
          render turbo_stream: [
            turbo_stream.replace('pinned_pages_list', partial: 'pinned_pages/list'),
            turbo_stream.replace('pin_button', partial: 'pinned_pages/pin_button',
                                               locals: { page_url: @pinned_page.page_url })
          ]
        end
      end
    else
      redirect_back fallback_location: root_path, alert: 'Unable to pin the page.'
    end
  end

  def destroy
    if @pinned_page&.destroy
      redirect_back fallback_location: root_path, success: 'Page unpinned successfully.'
    else
      redirect_back fallback_location: root_path, alert: 'Unable to unpin the page.'
    end
  end

  def manage
    add_breadcrumb 'Pinned shortcuts', manage_pinned_pages_path

    @pinned_pages = current_user.pinned_pages.order(:position)
  end

  def update_all
    ActiveRecord::Base.transaction do
      # Update the order of pinned pages
      params[:order].split(', ').each_with_index do |id, index|
        current_user.pinned_pages.find(id).update!(position: index + 1)
      end

      # Update the title of pinned pages
      params[:pinned_pages].each do |id, attributes|
        pinned_page = current_user.pinned_pages.find(id)
        pinned_page.update!(attributes.permit(:title))
      end
    end

    redirect_back fallback_location: root_path, success: 'Pinned pages updated successfully.'
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: root_path, alert: 'There was an issue updating the pinned pages.'
  end

  private

  def set_pinned_page = @pinned_page = current_user.pinned_pages.find_by(id: params[:id])

  def pinned_page_params = params.require(:pinned_page).permit(:title)
end
