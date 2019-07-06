require 'nokogiri'
require 'open-uri'
require 'json'

INFO_URL = "https://keiba.yahoo.co.jp/race/denma/"
RESULT_URL = "https://keiba.yahoo.co.jp/race/result/"
TANFUKU_URL = "https://keiba.yahoo.co.jp/odds/tfw/"
UMAREN_URL = "https://keiba.yahoo.co.jp/odds/ur/"
UMATAN_URL = "https://keiba.yahoo.co.jp/odds/ut/"
WIDE_URL = "https://keiba.yahoo.co.jp/odds/wide/"


namespace :scrape do
  desc "レース一覧の取得"
  task :race_list, ["year"] => :environment do |task, args|
    year = args["year"].to_i
    year_last_two_digits = year % 100

    def create_race_id(year, place, time, day, race)
      year.to_s.rjust(2, '0') + place.to_s.rjust(2, '0') + time.to_s.rjust(2, '0') + day.to_s.rjust(2, '0') + race.to_s.rjust(2, '0')
    end

    def todays_race_is_available?(year, place, time, day)
      begin
        race_id = create_race_id(year, place, time, day, 1)
        open(INFO_URL + race_id + "/").read
        return true
      rescue
        return false
      end
    end

    place = time = day = 1
    time_flag = place_flag = false
    while true
      if todays_race_is_available?(year_last_two_digits, place, time, day)
        (1..12).each do |race|
          race_id = create_race_id(year_last_two_digits, place, time, day, race)
          Race.find_or_create_by(no: race_id, year: year)
          p race_id
        end

        day += 1
        time_flag = place_flag = false
      else
        if time_flag
          if place_flag
            break
          else
            day = 1
            time = 1
            place += 1
            place_flag = true
          end
        else
          day = 1
          time += 1
          time_flag = true
        end
      end
    end
  end


  desc "レース情報の取得"
  task :race_info, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      race_info = {}

      p race
      begin
        html = open(INFO_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("p#raceTitMeta")

        infos = doc.text.split(" | ")
        course = infos[0].split(" ")
        race_info["kind"] = course[0].split("・")[0]
        race_info["direction"] = course[0].split("・")[1]
        race_info["distance"] = course[1].gsub(/[^\d]/, "").to_i
        imgs = doc.css("img")
        race_info["weather"] = imgs[0].attribute("alt").value
        race_info["condition"] = imgs[1].attribute("alt").value
        race_info["prize"] = infos[5].split("：")[1].split("、")[0].to_i

        race.update(kind: race_info["kind"],
                    direction: race_info["direction"],
                    weather: race_info["weather"],
                    condition: race_info["condition"],
                    distance: race_info["distance"],
                    prize: race_info["prize"])
      rescue
        p race.no
      end

    end
  end


  desc "レース結果の取得"
  task :race_result, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      p race.no
      begin
        html = open(RESULT_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("table#raceScore tr")
        doc.each do |tr|
          horse = {}
          if tr.css("td.txC").present?
            horse["result"] = tr.css("td.txC")[0].text.to_i
            horse["umaban"] = tr.css("td.txC")[2].text.to_i
          end

          unless horse["umaban"].nil?
            RaceResult.find_or_create_by(race_id: race.id,
                                         umaban: horse["umaban"],
                                         result: horse["result"])
          end
        end
      rescue
        p race.no
      end
    end
  end


  desc "単勝・複勝オッズの取得"
  task :tanfuku_odds, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      p race.no
      begin
        html = open(TANFUKU_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("table.oddTkwLs tr")
        doc.each do |tr|
          horse = {}
          if tr.css("td.txC").count > 1
            horse["umaban"] = tr.css("td.txC")[1].text.to_i
          end
          if tr.css("td.txR").count > 2
            horse["tan"] = tr.css("td.txR")[0].text.to_f
            horse["fuku"] = ((tr.css("td.txR")[1].text.to_f + tr.css("td.txR")[2].text.to_f) / 2).round(2)
          end

          unless horse["umaban"].nil?
            TanfukuOdds.find_or_create_by(race_id: race.id,
                                           umaban: horse["umaban"],
                                           tan: horse["tan"],
                                           fuku: horse["fuku"])
          end
        end
      rescue
        p race.no
      end
    end
  end


  desc "馬連オッズの取得"
  task :umaren_odds, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      p race.no
      begin
        html = open(UMAREN_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("table.oddsLs")
        doc.each do |table|
          first = table.css("th.oddsJk").text
          table.css("tr").each_with_index do |tr, index|
            if index > 0
              second = tr.css("th").text
              odds = tr.css("td").text.to_f

              UmarenOdds.find_or_create_by(race_id: race.id,
                                            first: first,
                                            second: second,
                                            odds: odds)
              UmarenOdds.find_or_create_by(race_id: race.id,
                                            second: first,
                                            first: second,
                                            odds: odds)
            end
          end
        end
      rescue
        p race.no
      end
    end
  end


  desc "馬単オッズの取得"
  task :umatan_odds, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      p race.no
      begin
        html = open(UMATAN_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("table.oddsLs")
        doc.each do |table|
          first = table.css("th.oddsJk").text
          table.css("tr").each_with_index do |tr, index|
            if index > 0
              second = tr.css("th").text
              odds = tr.css("td").text.to_f

              UmatanOdds.create(race_id: race.id,
                                 first: first,
                                 second: second,
                                 odds: odds)
            end
          end
        end
      rescue
        p race.no
      end
    end
  end


  desc "ワイドオッズの取得"
  task :wide_odds, ["year"] => :environment do |task, args|
    year = args["year"].to_i

    Race.where(year: year).each do |race|
      p race.no
      begin
        html = open(WIDE_URL + race.no + "/").read
        doc = Nokogiri::HTML.parse(html).css("table.oddsWLs")
        doc.each do |table|
          first = table.css("th.oddsWJk").text
          table.css("tr").each_with_index do |tr, index|
            if index > 0
              second = tr.css("th").text
              odds = ((tr.css("td.txR")[0].text.to_f + tr.css("td.txR")[1].text.to_f) / 2).round(2)

              WideOdds.create(race_id: race.id,
                               first: first,
                               second: second,
                               odds: odds)
              WideOdds.create(race_id: race.id,
                               second: first,
                               first: second,
                               odds: odds)
            end
          end
        end
      rescue
        p race.no
      end
    end
  end

end
