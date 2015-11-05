class ShowsController < ApplicationController
  before_action :find_show, only: [:show,:edit,:update,:destroy]

  def index
    n = 2
    t = Time.zone.now
    today = t.year.to_s + "-" + t.month.to_s.rjust(n, "0") + "-" + t.day.to_s.rjust(n, "0") 
    threeDays = t.tomorrow.tomorrow.tomorrow
    endDate = threeDays.year.to_s + "-" + threeDays.month.to_s.rjust(n, "0") + "-" + threeDays.day.to_s.rjust(n, "0") 

    # API REQUEST
    @response = Typhoeus::Request.new("http://api.bandsintown.com/events/search.json?location=San+Francisco,CA&date=#{today},#{endDate}&radius=10&app_id=777").run

    # API RESPONSE
    @response_body = JSON.parse(@response.response_body)

    puts @response_body

    # loop through the response
    # Make a new Show document per api response
    # store in the db
    # delete shows that have "expired"?

    @response_body.each do |show|

      # date --> gives back a DateTime object
      date = DateTime.parse(show["datetime"])

      unless show["on_sale_datetime"] == nil
      ticketDate = DateTime.parse(show["on_sale_datetime"])
      end

      artist = show["artists"][0]["name"]
      venue = show["venue"]["name"]
      latitude = show["venue"]["latitude"]
      longitude = show["venue"]["longitude"]
      tickets = show["ticket_url"]

      show = Show.create(
        title: artist,
        venue: venue,
        image_url: "www.google.com",
        attendance: 0,
        latitude: latitude, 
        longitude: longitude,
        showdate: date,
        saledate: ticketDate,
        showtime: date
        )
    end


    # All the user-defined shows in the db
    date = Date.today

    # Find all shows from today til 3 days from now in DB
    oneDay = date.tomorrow
    twoDays = date.tomorrow.tomorrow
    threeDays = date.tomorrow.tomorrow.tomorrow
    @shows = Show.where('showdate': date)
    @tomorrow = Show.where('showdate': oneDay)
    @dayAfter = Show.where('showdate': twoDays)
    @dayAfterThat = Show.where('showdate': threeDays)

    # Combine all current shows with future shows
    @tomorrow.each do |show|
      @shows.push(show)
    end
     @dayAfter.each do |show|
      @shows.push(show)
    end
     @dayAfterThat.each do |show|
      @shows.push(show)
    end
  end

  def new
    @show = Show.new
  end

  def create
    params[:show].parse_time_select! :time

    # find_user --> need to hold off on this until we have User up and runnign.
    #  But we need to push a show that a user created into a user's shows []
    @show = Show.new(show_params)

    # create showTime w/ the other 2 params
    # parse the time and showdate
    # @show.showTime = some logic
    @show.showtime = Time.zone.local(@show.showdate.year,
                      @show.showdate.month,
                      @show.showdate.day,
                      @show.time.hour,
                      @show.time.min,
                      @show.time.sec
                      )
      if @show.save
       flash[:success] = "New Show Created!"
       redirect_to root_path
      else
      render :new
     end
  end

  # render the edit form
  def edit
  end

  def update

    params[:show].parse_time_select! :time
    @show.update(show_params)
    @show.showtime = Time.zone.local(@show.showdate.year,
                      @show.showdate.month,
                      @show.showdate.day,
                      @show.time.hour,
                      @show.time.min,
                      @show.time.sec
                      )
    if@show.save
      flash[:success] = "#{@show.title} has been updated!"
      redirect_to root_path
    else
      render :edit
    end
  end

  # MODAL --> Shouldn't navigate away from index page
  def show
  end

  def destroy
    @show = Show.find params[:id]
    @show.destroy
    flash[:alert] = "#{@show.title} has been deleted"
    redirect_to root_path
  end
   
   private

     def show_params
        params.require(:show).permit(
          :title,
          :venue,
          :image_url,
          :description,
          :genre,
          :price,
          :showdate,
          :saledate,
          :address,
          :time
          )
     end

    def find_user
      @user = current_user
    end

    def find_show
      @show = Show.find params[:id]
    end
end



