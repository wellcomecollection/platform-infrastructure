def get_ecs_cluster_arns(ecs_client):
    """
    Generates the ARN of every ECS cluster in your AWS account.
    """
    paginator = (ecs_client).get_paginator("list_clusters")

    for page in paginator.paginate():
        yield from page["clusterArns"]
