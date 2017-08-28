# frozen_string_literal: true

module Alchemy
  class Api::ElementsController < Api::BaseController
    before_action :load_element, only: [:show, :update]

    # Returns all elements as json object
    #
    # You can either load all or only these for :page_id param
    #
    # If you want to only load a specific type of element pass ?named=an_element_name
    #
    def index
      @elements = Element.accessible_by(current_ability, :index)
      if params[:page_id].present?
        @elements = @elements.where(page_id: params[:page_id])
      end
      if params[:named].present?
        @elements = @elements.named(params[:named])
      end
      respond_with @elements
    end

    # Returns a json object for element
    #
    def show
      authorize! :show, @element
      respond_with @element
    end

    def update
      authorize! :update, @element

      if @element.update(element_params)
        respond_with @element
      else
        render json: {
          error: 'Invalid resource',
          errors: @element.errors.to_hash
        }, status: 422
      end
    end

    private

    def load_element
      @element = Element.find(params[:id])
    end

    def element_params
      params.require(:element).permit(:folded, :public)
    end
  end
end
