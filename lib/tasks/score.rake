namespace :score do

  desc "スコアリング"
  task :scoring => :environment do
    races = Race.first(10)

    races.each do |race|
      # 単勝
      tan_pops = []
      tans = TanfukuOdds.where(race: race.id).order(:tan)
      tans.each do |tan|
        tan_pops.push(tan.umaban)
      end

      # 複勝
      fuku_pops = []
      fukus = TanfukuOdds.where(race: race.id).order(:fuku)
      fukus.each do |fuku|
        fuku_pops.push(fuku.umaban)
      end

      # 馬連
      umaren_maps = []
      umarens = UmarenOdds.where(race: race.id)
      (1..tan_pops.size).each do |index|
        umaren_maps.push({ umaban:index, odds: umarens.where(first: index).sum(:odds) })
      end

      umaren_pops = []
      umaren_maps = umaren_maps.sort { |a, b| a[:odds] <=> b[:odds] }
      umaren_maps.each do |umaren_map|
        umaren_pops.push(umaren_map[:umaban])
      end

      # 馬単
      umatan_maps = []
      umatans = UmatanOdds.where(race: race.id)
      (1..tan_pops.size).each do |index|
        umatan_maps.push({ umaban:index, odds: umatans.where(first: index).sum(:odds) })
      end

      umatan_pops = []
      umatan_maps = umatan_maps.sort { |a, b| a[:odds] <=> b[:odds] }
      umatan_maps.each do |umatan_map|
        umatan_pops.push(umatan_map[:umaban])
      end

      # ワイド
      wide_maps = []
      wides = WideOdds.where(race: race.id)
      (1..tan_pops.size).each do |index|
        wide_maps.push({ umaban:index, odds: wides.where(first: index).sum(:odds) })
      end

      wide_pops = []
      wide_maps = wide_maps.sort { |a, b| a[:odds] <=> b[:odds] }
      wide_maps.each do |wide_map|
        wide_pops.push(wide_map[:umaban])
      end

      scores = {}
      tan_pops.each_with_index do |tan, index|
        scores[tan] = 0

        fuku_index = fuku_pops.find_index(tan)
        scores[tan] += index - fuku_index if fuku_index < index

        umaren_index = umaren_pops.find_index(tan)
        scores[tan] += index - umaren_index if umaren_index < index

        umatan_index = umatan_pops.find_index(tan)
        scores[tan] += index - umatan_index if umatan_index < index

        wide_index = wide_pops.find_index(tan)
        scores[tan] += index - wide_index if wide_index < index

        # puts("#{tan} #{fuku_pops[index]} #{umaren_pops[index]} #{umatan_pops[index]} #{wide_pops[index]}")
      end

      puts scores
    end
  end

end
