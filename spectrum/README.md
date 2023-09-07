# Amazon Redshift Spectrum のサンプル

---

* Amazon S3 バケットにデータを用意
  - ここでは、tnobe-redshift-databucket バケットの /data フォルダに stock_prices.csv を格納している前提

---

## 外部テーブルの作成とクエリ発行

* スキーマの作成

```sql
CREATE EXTERNAL SCHEMA spectrum
FROM DATA CATALOG
DATABASE 'spectrumdb'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;
```
* 外部テーブルの作成

```sql
DROP TABLE IF EXISTS spectrum.stocksummary;
CREATE EXTERNAL TABLE spectrum.stocksummary(
    Trade_Date DATE,
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://tnobe-redshift-databucket/data/'
table properties ('skip.header.line.count'='1');
```
* クエリ発行（2021年9月9日に取引された株式の詳細）

```sql
SELECT * FROM spectrum.stocksummary WHERE Trade_Date LIKE '2021-09-09' ORDER BY Ticker;
```

## INSERT INTO SELECT によるデータの追加 

* 追加対象のデータをもつテーブルを用意

```sql
CREATE TABLE stock_insert(
    Trade_Date DATE,
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)

INSERT INTO stock_insert VALUES ('2024-01-01','demo',1,1,1,1,1,1);
INSERT INTO stock_insert VALUES ('2024-01-02','demo',2,2,2,2,2,2);
INSERT INTO stock_insert VALUES ('2024-01-03','demo',3,3,3,3,3,3);
INSERT INTO stock_insert VALUES ('2024-01-04','demo',4,4,4,4,4,4);
INSERT INTO stock_insert VALUES ('2024-01-05','demo',5,5,5,5,5,5);

SELECT * FROM stock_insert;
```

* 外部テーブルへ INSERT INTO SELECT 発行

```sql
INSERT INTO spectrum.stocksummary SELECT * FROM stock_insert;
```

---

## CREATE TABLE AS SELECT (CTAS) 

* CTAS で外部テーブル作成

```sql
CREATE EXTERNAL TABLE spectrum.sales2008
STORED AS PARQUET
LOCATION 's3://tnobe-redshift-databucket/ctas/' 
AS ( select * from sales);
```

* CTAS で作成した外部テーブルへクエリ発行

```sql
SELECT sellerid, username, (firstname ||' '|| lastname) AS name,
city, avg(qtysold)
FROM spectrum.sales2008 s, date, users
WHERE s.sellerid = users.userid
AND s.dateid = date.dateid
AND city = 'San Diego'
GROUP BY sellerid, username, name, city
ORDER BY 5 DESC
LIMIT 5;
```

---

* テーブルとスキーマの削除

```sql
DROP TABLE     spectrum.stocksummary;
DROP SCHEMA    spectrum;
```