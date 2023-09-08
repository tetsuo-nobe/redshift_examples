# AUTO 分散

---

* sales テーブルと events テーブルを作成し、分散方法が自動的に変更されることを確認する

---

* sales テーブルと event テーブルの作成

```sql

CREATE SCHEMA automgmt;
SET search_path = automgmt;
select current_schema();

CREATE TABLE events (
    eventid bigint NOT NULL,
    event_category VARCHAR(30) NOT NULL
);

CREATE TABLE sales (
    salesid bigint NOT NULL,
    saletime timestamp without time zone NOT NULL,
    sale_category varchar(20) NOT NULL,
    eventid bigint NOT NULL,  
    qtysold integer NOT NULL,
    pricepaid numeric(11,2) NOT NULL,
    commission numeric(11,2) NOT NULL,
    saleyear smallint NOT NULL,
    salemonth smallint NOT NULL,
    saleday smallint NOT NULL
);
```

* この時点の分散方法を確認

```sql
SELECT trim(nspname) as schemaname,trim(relname) as tablename,
CASE WHEN "reldiststyle" = 0 THEN 'EVEN'::text
     WHEN "reldiststyle" = 1 THEN 'KEY'::text
     WHEN "reldiststyle" = 8 THEN 'ALL'::text
     WHEN "releffectivediststyle" = 10 THEN 'AUTO(ALL)'::text
     WHEN "releffectivediststyle" = 11 THEN 'AUTO(EVEN)'::text ELSE '<<UNKNOWN>>'::text END as diststyle,relcreationtime
FROM pg_class_info a left join pg_namespace b on a.relnamespace=b.oid
WHERE trim(relname) in ('sales','events');
```

* sales テーブルと events テーブルにデータを COPY する
```sql
COPY events
FROM 's3://tnobe-redshift-databucket/datawarehouse/events/'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole' DELIMITER '|'  GZIP;

COPY sales
FROM 's3://tnobe-redshift-databucket/datawarehouse/sales/'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole' DELIMITER '|'  GZIP;
```

* データを COPY 後の分散方法を確認

```sql
SELECT trim(nspname) as schemaname,trim(relname) as tablename,
CASE WHEN "reldiststyle" = 0 THEN 'EVEN'::text
     WHEN "reldiststyle" = 1 THEN 'KEY'::text
     WHEN "reldiststyle" = 8 THEN 'ALL'::text
     WHEN "releffectivediststyle" = 10 THEN 'AUTO(ALL)'::text
     WHEN "releffectivediststyle" = 11 THEN 'AUTO(EVEN)'::text ELSE '<<UNKNOWN>>'::text END as diststyle,relcreationtime
FROM pg_class_info a left join pg_namespace b on a.relnamespace=b.oid
WHERE trim(relname) in ('sales','events');
```