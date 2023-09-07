# 自動コピー (2023/09 現在 Preview 機能)

---

* Amazon S3 バケット tnobe-redshift-autocopy の autocopy フォルダのファイルを自動コピーする

---

* COPY JOB によるデータの COPY 先のテーブルの作成
```sql
CREATE TABLE customers (
  customer_id    integer primary key,
  customer_name  varchar
);
```


* COPY JOB の作成

```sql
COPY customers
FROM 's3://tnobe-redshift-autocopy/autocopy'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole'
CSV
region 'ap-northeast-1'
JOB CREATE customers_csv AUTO ON;
```

* コピーJOBの削除
```sql
COPY JOB DROP customers_csv
```

* コピージョブの一覧
```sql
SELECT * 
  FROM sys_copy_job;
```

```sql
COPY JOB LIST
```

* コピージョブの集計を取得する
```sql
SELECT *
  FROM sys_load_history
 WHERE copy_job_id = 105927;
```

* コピージョブの詳細を取得する
```sql
SELECT *
  FROM stl_load_commits
 WHERE copy_job_id = 105927
ORDER BY curtime ASC;
```

* コピージョブのエラーの詳細を取得する
```sql
SELECT *
  FROM stl_load_errors
 WHERE copy_job_id = 105927;
```