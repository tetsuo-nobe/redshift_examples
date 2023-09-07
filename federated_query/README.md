# Amazon Redshift フェデレーティッドクエリのサンプル

---

* Amazon Aurora Serverless for PostgreSQL の stocks テーブルにデータを用意
* この データベースの認証情報を AWS Secrets Manager のシークレット AuroraSecrets に格納している前提
---

## 外部スキーマの作成とクエリ発行

* スキーマの作成

```sql
CREATE EXTERNAL SCHEMA federated
FROM POSTGRES
DATABASE 'stocksummary'
URI 'aurora-serverless-postgresql.cluster-xxx.ap-northeast-1.rds.amazonaws.com'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole'
SECRET_ARN 'arn:aws:secretsmanager:ap-northeast-1:000000000000:secret:AuroraSecrets';
```

* クエリ発行（2021年9月9日に取引された株式の詳細）

```sql
SELECT * FROM federated.stocks WHERE Trade_Date LIKE '2021-09-09' ORDER BY Ticker;
```

* スキーマの削除

```sql
DROP SCHEMA federated;
```
