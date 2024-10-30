locals {
    input_paths ={
      alarmName     = "$.detail.alarmName",
      reason        = "$.detail.state.reason"
      state         = "$.detail.state.value"
      description   = "$.detail.configuration.description"
    }

    input_template_alarm = <<EOF
{
    "version": "1.0", 
    "source": "custom", 
    "content": {
        "textType": "client-markdown",
        "title": ":rotating_light: <https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#alarmsV2:alarm/<alarmName>|<alarmName>>: <description>",  
        "description": "(<state>) <reason>"
    },
    "metadata": {
        "threadId": "<alarmName>"
    }
}
EOF

    input_template_ok = <<EOF
{
    "version": "1.0", 
    "source": "custom", 
    "content": {
        "textType": "client-markdown",
        "title": ":ok: <https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#alarmsV2:alarm/<alarmName>|<alarmName>>: <description>",  
        "description": "(<state>) <reason>"
    },
    "metadata": {
        "threadId": "<alarmName>"
    }
}
EOF
}