require "json"
require "open-uri"

class ResultsController < ApplicationController
  def index
    # TODO: return all results with image paths
    # set the instances
    @results = Menu.find(params[:menu_id]).results
    @results_with_data = {}
    # search images for each food
    t = Time.now
    search_image_for_each_food
    puts "=============#{Time.now - t}"
  end

  def order
    @orders = Result.where("order > ?", 0)
    @images = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROOxkx63-nDWNxgEFCIIDxg4EIB8A16PLTaGfEttPEqFgvtkO8aN9yhtM",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCHPLNtU2fTUJvbA6T7-LNhf6PiTHmJDrlyymgR3vr5jm-O90JgjOdtjI",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUoMnJPRsuCb6FR0DWeEICML84nDYIXLGN7mxKB5xahU9yZ-82JrNxZ7x0",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEbm52BNP-3N9KeD1B-WnC7N6lxIhLG6SWLuP0U82zkHfXeaqUovXx09og",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-Wz7HyCHbgr3AEG4XFfQglZvVh_cdvUOc7BdT7-ajRAJimYytCU3xEDTW",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5ccGlcyS-uo0PNMVimcpP9pgQptx3Gbf50uLcjOmqkOYmlUfpYBil_mPb",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUzJYxy5Jn-mH2nXSzVNvhmg2pKUjj7OTCS_G2eL_8UsIPU6CafCu76mQ",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfw_DGC8E2LiFCI37v_z5L0gQF3pFhqngKf22hBykX_ESPOybDaB9wjIYp",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMAUsY6QemwF48ujlv2et21tPbe1_rQVzeGpyv3L1IkzdyXiXB78jsCog",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQi-uTxIS9sz--YeEuhNbIBYGSeN2j0W3c7KUpEg_DxuyaJRi-yc5QTAITo"
  ]

    @menu = Menu.where(user_id: current_user.id)
    url = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=udon"

    food_wiki= JSON.parse(open(url).read)
    @food_title = food_wiki["query"]["pages"].values[0]["title"]
    @food_summary = food_wiki["query"]["pages"].values[0]["extract"]
  end

  private

  def search_image_for_each_food
    # boost threads to imcrease performance
    pool = Concurrent::FixedThreadPool.new(10)
    completed = []
    @results.each do |result|
      pool.post do
        # ==========================================
        # ***** FOP DEVELOPMENT purpose *****
        # @results_with_data[result] = [Food::SAMPLE_IMAGES.sample]
        # ***** FOP PRODUCTION purpose *****
        # call searhcimages method and store the returned array
        @results_with_data[result] = SearchImages.call(result.food.name)
        # ==========================================
        completed << 1
      end
    end
    # temporary measure: wait_for_termination does not work well
    sleep(1) unless completed.count == @results.count
    pool.shutdown
    pool.wait_for_termination
  end
end
