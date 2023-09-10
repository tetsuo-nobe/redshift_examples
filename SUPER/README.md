# SUPER 型を使用したテーブルの作成とクエリ

---

* テーブルとデータの準備

```sql
create table demo_customers (
  id INTEGER,
  name SUPER,
  phone SUPER
);

insert into demo_customers values (1,
JSON_PARSE('{ "first":  "John","last":   "Doe"}'),
JSON_PARSE('[ {"type": "work","number":"031111111"},{"type": "cell","number":"0901111111"}]');
)

insert into demo_customers values (2,
JSON_PARSE('{ "first":  "Jack","last":   "Doe"}'),
JSON_PARSE('[ {"type": "work","number":"031111111"}]')
);
```

* クエリ例 1 

```sql
SELECT
 name.first AS firstname,
 ph.number
FROM
 demo_customers c,
 c.phone ph
WHERE 
 ph.type = 'cell';
```

* クエリ例 2

```sql
SELECT cast(name.first as varchar) FROM demo_customers;
```