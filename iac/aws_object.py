import boto3

def generate_secret():
  client = boto3.client('secretsmanager')
  response = client.get_random_password(
    PasswordLength=32,
    ExcludeNumbers=False,
    ExcludePunctuation=True,
    ExcludeUppercase=False,
    ExcludeLowercase=False,
    IncludeSpace=False,
    RequireEachIncludedType=False
  )
  return response['RandomPassword']

def get_secret_value(rds_name):
  client = boto3.client('secretsmanager')
  try:
    response = client.describe_secret(
      SecretId='rds-admin-secret-'+rds_name
    )
  except client.exceptions.ResourceNotFoundException:
    return generate_secret()
  else:
    response = client.get_secret_value(
      SecretId='rds-admin-secret-'+rds_name
    )
    return response['SecretString']