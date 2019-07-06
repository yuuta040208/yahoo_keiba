# yahoo_keiba

Yahoo競馬からオッズ情報をスクレイピングして、AI（オッズ理論）で予想する。


## バージョン情報

Ruby 2.5.3
Rails 5.2.2
MySQL 5.7


## 環境構築手順

```
$ git clone https://github.com/evitch040208/yahoo_keiba.git
$ cd yahoo_keiba
$ docker-compose build
$ gem install bundler
$ bundle install --path vendor/bundle
$ docker-compose up -d
```


## スクレイピングスクリプトの使い方

全年を対象にするとデータ量が膨大になるため、1年ずつスクレイピングする。

1. レース一覧を取得
    ```
    $ bundle exec rake scrape:race_list[2015]
    ```

1. レース詳細情報を取得
    ```
    $ bundle exec rake scrape:race_info[2015]
    ```

1. レース結果を取得
    ```
    $ bundle exec rake scrape:race_result[2015]
    ```

* 単勝・複勝オッズを取得
    ```
    $ bundle exec rake scrape:tanfuku_odds[2015]
    ```

* 馬連オッズを取得
    ```
    $ bundle exec rake scrape:umaren_odds[2015]
    ```

* 馬単オッズを取得
    ```
    $ bundle exec rake scrape:umatan_odds[2015]
    ```

 * ワイドオッズを取得
     ```
     $ bundle exec rake scrape:wide_odds[2015]
     ```
