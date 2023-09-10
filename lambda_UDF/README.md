# AWS Lambda ユーザー定義関数 (UDF)

---

* クエリで 関数の引数に指定された顧客キーに該当する顧客名を Amazon DynamoDB から取得する
* 参考: AWS Blog [Accessing external components using Amazon Redshift Lambda UDFs](https://aws.amazon.com/jp/blogs/big-data/accessing-external-components-using-amazon-redshift-lambda-udfs/)
---

* AWS Lambda 関数 Lambda_DynamoDB_Lookup のコード (Python)

```python
import json
import boto3
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
 ret = dict()
 try: 
  tableName = event["arguments"][0][0]
  columnName = event["arguments"][0][1]

  table = dynamodb.Table(tableName)
  table.item_count 
  res = []
  for argument in event['arguments']:
   try:
    columnValue = argument[2]
    response = table.get_item(Key={columnName: columnValue })
    res.append(json.dumps(response["Item"]))
   except: 
    res.append(None)
  ret['success'] = True
  ret['results'] = res
 except Exception as e:
  ret['success'] = False
  ret['error_msg'] = str(e)
 return json.dumps(ret)
```

* Amazon Redshift ユーザー定義関数の作成

```sql
CREATE OR REPLACE EXTERNAL FUNCTION udf_dynamodb_lookup (tableName varchar, columnName varchar, columnValue varchar)
RETURNS varchar STABLE
LAMBDA 'Lambda_DynamoDB_Lookup'
IAM_ROLE 'arn:aws:iam::000000000000:role/service-role/AmazonRedshift-CommandsAccessRole';
```

* 作成したユーザー定義関数の使用

```sql
CREATE TABLE udf_transactions (CustomerId varchar, StoreId varchar, TransactionAmount decimal(10,4));
INSERT INTO udf_transactions VALUES
('0', '123', '10.34'),
('1', '123', '9.99'),
('2', '234', '10.34'),
('3', '123', '4.15'),
('4', '234', '17.25'),
('12', '123', '9.99');

SELECT
  CustomerId,
  udf_dynamodb_lookup ('Customer', 'id', CustomerId) Customer
FROM udf_transactions;
```

* 結果の例

```
customerid    customer
0	            NULL	
1	            {"lname": "Doe", "id": "1", "fname": "John"}	
2	            {"lname": "Doe", "id": "2", "fname": "Jane"}	
3	            {"lname": "Salazar", "id": "3", "fname": "Carlos"}	
4	            {"lname": "Ramirez", "id": "4", "fname": "Diego"}	
12	            NULL	
``````