locals {
  env_var_string = jsonencode([
    for key in sort(keys(var.secret_env_vars)) :
    {
      name      = key
      valueFrom = "/aws/reference/secretsmanager/${lookup(var.secret_env_vars, key)}"
    }
  ])
}
