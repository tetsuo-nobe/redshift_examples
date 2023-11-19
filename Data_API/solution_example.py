# Write your code here and run the cell.
# Hint - Except for the query, the rest of the code is the same as the previous cell.
query_str = "select * from stocksummary.stocks \
where ticker = 'tsla' \
order by volume limit 10;"

res = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query_str, ClusterIdentifier= cluster_id)
print("Redshift Data API execution  started ...")
id = res["Id"]

# Waiter in try block and wait for DATA API to return.
try:
    custom_waiter.wait(Id=id)
    print("Done waiting to finish Data API.")
except WaiterError as e:
    print (e)
    
output=client_redshift.get_statement_result(Id=id)
nrows=output["TotalNumRows"]
ncols=len(output["ColumnMetadata"])
resultrows=output["Records"]

col_labels=[]
for i in range(ncols): col_labels.append(output["ColumnMetadata"][i]['label'])
                                              
# Load the results into a dataframe.
df = pd.DataFrame(np.array(resultrows), columns=col_labels)

# Reformatting the results before display.
for i in range(ncols): 
    df[col_labels[i]]=df[col_labels[i]].apply(operator.itemgetter('stringValue'))

df
