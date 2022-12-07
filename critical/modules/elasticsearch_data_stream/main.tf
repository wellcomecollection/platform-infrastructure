resource "elasticstack_elasticsearch_index_lifecycle" "stream_lifecycle" {
  name = "${var.stream_name}-ilm"

  hot {
    rollover {
      max_age = var.index_rollover_max_age
    }
  }

  delete {
    min_age = var.index_delete_after
    delete {}
  }
}

resource "elasticstack_elasticsearch_index_template" "stream_template" {
  name = "${var.stream_name}-template"

  index_patterns = ["${var.stream_name}*"]
  priority       = 1

  template {
    settings = jsonencode({
      "lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.stream_lifecycle.name
    })
  }

  data_stream {}
}

resource "elasticstack_elasticsearch_data_stream" "stream" {
  name = var.stream_name
  depends_on = [
    elasticstack_elasticsearch_index_template.stream_template
  ]
}
