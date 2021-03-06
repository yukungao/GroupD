class Merchant::RestaurantsController < Merchant::MerchantController

  def index
    restaurants = Restaurant.open_by_merchant(@merchant.id)
    render json: Response::JsonResponse.new(restaurants)
  end

  def new
    if Restaurant.name_valid? @name
      render nothing: true
    else
      render json: Response::JsonResponse.new(nil, 
        warning: I18n.t('warning.DUPLICATE_RESTAURANT_NAME')), 
        status: :conflict
    end
  end

  def create
    Restaurant.create_restaurant @merchant.id, @name, @location, 
      @image_url, @category, @city
    render nothing: true, status: :created
  end

  def update
    @restaurant.update @name, @location, @image_url
    render nothing: true
  end

  def destroy
    @restaurant.close
    render nothing: true
  end

  private
    
    def params_sanitization
      sanitize :destroy, merchant_id: :merchant, id: :restaurant
      sanitize :update, merchant_id: :merchant, id: :restaurant, 
        name: :name, location_id: :location, image_url: :url
      sanitize :create, merchant_id: :merchant, name: :name, 
        location_id: :location, image_url: :url, 
        category_id: :category, city_id: :city
      sanitize :index, merchant_id: :merchant
      sanitize :new, name: :name
    end

    def authorization
      authorize [:destroy, :update] do
        @merchant.id == current_account.id && \
          @restaurant.merchant_id == @merchant.id
      end

      authorize [:create, :index] do
        @merchant.id == current_account.id
      end
    end
end
