require 'nokogiri'
require 'open-uri'
require 'json'

INFO_URL = "https://keiba.yahoo.co.jp/race/denma/"
RESULT_URL = "https://keiba.yahoo.co.jp/race/result/"
TANFUKU_URL = "https://keiba.yahoo.co.jp/odds/tfw/"
UMAREN_URL = "https://keiba.yahoo.co.jp/odds/ur/"
UMATAN_URL = "https://keiba.yahoo.co.jp/odds/ut/"
WIDE_URL = "https://keiba.yahoo.co.jp/odds/wide/"
TOP_URL = "https://keiba.yahoo.co.jp"


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
        p race_info
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


  desc "今週末のレース情報を取得"
  task weekend: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE this_week_races;")

    html = open(TOP_URL).read
    doc = Nokogiri::HTML.parse(html).css("table.topRaceInfo")

    dates = []
    doc[1].css("th").each_with_index do |th, i|
      dates[i] = th.text
    end

    divide = doc[1].css("td.topRaceInfoDay").size / dates.size
    doc[1].css("td.topRaceInfoDay").each_with_index do |td, count|
      hold = td.text
      link = td.css("a")[0][:href]
      sub_html = open(TOP_URL + link).read
      sub_doc = Nokogiri::HTML.parse(sub_html).css("table.scheLs")
      sub_doc.css("tr").each_with_index do |tr, i|
        if i.odd?
          begin
            no = tr.css("td")[0].text.split("R")[0].to_i
            time = tr.css("td")[0].text.split("R")[1]
            name = tr.css("td")[1].text.split("\n")[0]
            info = tr.css("td")[2].text
            distance = tr.css("td")[3].text

            ThisWeekRace.create(date: dates[(count / divide).to_i],
                                hold: hold,
                                no: no,
                                time: time,
                                name: name,
                                info: info,
                                distance: distance)
          rescue
            p "error"
          end
        end
      end
    end
  end

end
