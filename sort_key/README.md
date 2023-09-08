# ソートキー

---

* 適切にソートキーを設定した場合としない場合のクエリ時間の差異を確認する。（各テーブルの列やデータ型、格納しているデータは同じ）
  - ソートキーを設定したテーブル: automgmt.sales
  - ソートキーを設定していないテーブル: automgmt.sales_nosort

---

* sales テーブルにソートキーを設定

```sql
ALTER TABLE automgmt.sales ALTER SORTKEY (saleyear, salemonth);
```

* ソートキーを確認

```sql
SELECT "table", diststyle, sortkey1
FROM svv_table_info
WHERE "table" IN ('sales','sales_nosort') 
AND database='dev'
AND schema = 'automgmt'
ORDER BY 1;
```

* 次の手順で計測に使用する SQL (sales テーブル用)

```sql
SELECT s.saleyear,s.salemonth,e.event_category, sum(s.commission), sum(s.pricepaid)
FROM sales s, events e
WHERE s.saleyear between 2021 and 2022 and s.salemonth=1
AND s.eventid = e.eventid
GROUP BY s.saleyear,s.salemonth,e.event_category
ORDER BY s.saleyear,s.salemonth;
```

* 次の手順で計測に使用する SQL (sales_nosort テーブル用)

```sql
SELECT s.saleyear,s.salemonth,e.event_category, sum(s.commission), sum(s.pricepaid)
FROM sales_nosort s, events e
WHERE s.saleyear between 2021 and 2022 and s.salemonth=1
AND s.eventid = e.eventid
GROUP BY s.saleyear,s.salemonth,e.event_category
ORDER BY s.saleyear,s.salemonth;
```

* sales テーブルと sales_nosort テーブルに繰り返しクエリを発行し時間を計測
```sh
export PGPASSWORD=xxxxxxx
for i in {00..05}; do psql -U dbadmin -h demo-cluster.xxxxxxx.ap-northeast-1.redshift.amazonaws.com -d dev -p 5439 -f compare-sort.sql; sleep 2; done
```

---

* ソートキーの削除と変更

```sql
ALTER TABLE automgmt.sales ALTER SORTKEY NONE;
ALTER TABLE automgmt.sales ALTER SORTKEY AUTO;
```