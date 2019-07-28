class RacesController < ApplicationController
  def index
    @races = ThisWeekRace.all
    @dates = @races.pluck(:date).uniq
    @holds = @races.pluck(:hold).uniq
  end

  def show
    @race = ThisWeekRace.find(params[:id])
  end
end
