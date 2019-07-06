namespace :score do

  desc "スコアリング"
  task :scoring => :environment do
    race = Race.first

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

    tan_pops.each_with_index do |tan, index|
      puts("#{tan} #{fuku_pops[index]} #{umaren_pops[index]} #{umatan_pops[index]}")
    end
  end

end
