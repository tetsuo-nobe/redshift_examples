# 行レベルセキュリティ(RLS)のサンプル

---

* 前提
  - 全国の営業所の社員の評定テーブル(personal_eval)がある。
  - 人事マネージャー(hr_roleを付与)はすべての社員データにアクセス可能だが、関西エリアのマネージャー(hr_kansai_roleを付与)は関西地区の社員データにしかアクセスできないようにする。
  - 行レベルセキュリティの設定は、Redshift のスーパーユーザーで行う

---

### 設定

* テーブルの作成

```sql
CREATE TABLE public.personal_eval (
    id varchar(50) ,
    name varchar(100) ,
    deptid varchar(50) ,
    year integer ENCODE ,
    eval integer ENCODE 
);


INSERT INTO personal_eval VALUES 
(1,'A','Tokyo',2023,4),
(2,'B','Yokohama',2023,5),
(3,'C','Chiba',2023,3),
(4,'D','Osaka',2023,4),
(5,'E','Kobe',2023,5),
(6,'F','Kyoto',2023,4)
;
```

* ロールの作成と テーブルへのSELECT の許可

```sql
CREATE ROLE hr_role;
CREATE ROLE hr_kansai_role;

GRANT SELECT ON personal_eval to ROLE hr_role;
GRANT SELECT ON personal_eval to ROLE hr_kansai_role;
```

* ユーザーの作成とロールの付与

```sql
CREATE USER hrman WITH PASSWORD 'Redshift123';
CREATE USER nobe WITH PASSWORD 'Redshift123';

GRANT ROLE hr_role to hrman;
GRANT ROLE hr_kansai_role  to nobe;

SELECT user_is_member_of('hrman', 'hr_role');
SELECT user_is_member_of('nobe', 'hr_kansai_role');
```

* 行レベルセキュリティのポリシー作成

```sql
CREATE RLS POLICY  all_policy 
USING (true);

CREATE RLS POLICY  kansai_policy 
WITH (deptid varchar(50)) 
USING (deptid in ('Osaka','Kobe', 'Kyoto'));
```

* 行レベルセキュリティポリシーをテーブルにアタッチ

```sql
ATTACH RLS POLICY all_policy ON personal_eval TO ROLE hr_role;
ATTACH RLS POLICY kansai_policy ON personal_eval TO ROLE hr_kansai_role;
```

* 行レベルセキュリティーを有効化

```sql
ALTER TABLE personal_eval ROW LEVEL SECURITY on;
```

---
### 動作確認

* hrman ユーザーで personal_eval テーブルの全ての行にアクセス可能

```sql
SET SESSION AUTHORIZATION 'hrman';

SELECT current_user;

SELECT * FROM PERSONAL_EVAL;
```

* nobe ユーザーで personal_eval テーブルのdeptid が関西地区の行しかアクセスできない

```sql
SET SESSION AUTHORIZATION 'nobe';

SELECT current_user;

SELECT * FROM PERSONAL_EVAL;
```

---

### 設定削除

* **Redshift のスーパーユーザーで操作する**

```sql
REVOKE select on personal_eval FROM ROLE hr_role, ROLE hr_kansai_role;

ALTER TABLE personal_eval ROW LEVEL SECURITY off;
DROP TABLE PERSONAL_EVAL CASCADE;

DROP RLS POLICY all_policy;
DROP RLS POLICY kansai_policy;

DROP USER hrman;
DROP USER nobe;

DROP ROLE hr_role;
DROP ROLE hr_kansai_role;
```

