
<!-- README.md is generated from README.Rmd. Please edit that file -->
jpndistrict <img src="logo.png" align="right" width="80px" />
=============================================================

[![Travis-CI Build Status](https://travis-ci.org/uribo/jpndistrict.svg?branch=master)](https://travis-ci.org/uribo/jpndistrict) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/jpndistrict)](https://cran.r-project.org/package=jpndistrict) [![codecov](https://codecov.io/gh/uribo/jpndistrict/branch/master/graph/badge.svg)](https://codecov.io/gh/uribo/jpndistrict)

*English version of README is [here](https://github.com/uribo/jpmesh/blob/master/README.en.md)*

Overview
--------

本パッケージが提供する行政区域データは国土交通省国土政策局「[国土数値情報（行政区域データ 平成27年4月1日時点のデータ）](http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03.html) 」をもとに瓜生真也が編集・加工を行ったものです。そのため、このデータを利用した二次著作物を作成する際は、国土数値情報の利用約款に準拠するものとします。

Installation
------------

**`{jpndistrict}`**は**`{devtool}`**パッケージを利用して開発版をインストール可能です。

``` r
install.packages("devtools")
devtools::install_github("uribo/jpndistrict")
```

Usage
-----

基本的な使い方を説明します。

``` r
# パッケージの読み込み
library(jpndistrict)
```

### 行政区域データの取得

-   `spdf_jpn_pref()`... 都道府県全体の行政区域データ。引数district = FALSEで市区町村の区域のないデータを返します
-   `spdf_jpn_cities()`... `spdf_jpn_pref()`の都道府県行政区域データから、特定の市区町村のみを指定できます

``` r
spdf_jpn_pref(14)
spdf_jpn_pref(14, district = FALSE)
spdf_jpn_cities(spdf_jpn_pref(14), admin_name = "海老名市")
spdf_jpn_cities(jis_code_pref = 33, admin_name = c("倉敷市", "笠岡市"))
```

### 特徴

-   `spdf_jpn_*()`関数が返す行政区域データはSpatialPolygonDataframeクラスです
-   base, ggplot2, leaflet, plotlyといった各種の地図描画システムに対応しています。詳細は[vignettes](vignettes/create_map.Rmd)に書いてあります。
-   都道府県コード、市区町村コードによる指定が可能です

今後の展望: Roadmap
-------------------

-   \[ \] テストコードの充実
-   \[x\] CI環境の構築
-   \[ \] Vignettes、ドキュメントの整備
-   \[ \] CRANへの登録
-   \[ \] Shinyアプリケーション実装

### 開発履歴: History

-   `2016-10-22` 開発に着手。 `v0.0.9999`
-   `2016-11-04` GitHubへのpush
