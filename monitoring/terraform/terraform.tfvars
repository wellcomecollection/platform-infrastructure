key_name = "wellcomedigitalplatform"

admin_cidr_ingress = "195.143.129.128/25"

infra_bucket = "wellcomecollection-platform-infra"

dashboard_assumable_roles = [
  "arn:aws:iam::130871440101:role/platform-team-assume-role",
  "arn:aws:iam::299497370133:role/platform-team-assume-role",
]

rds_username = "wellcome"

rds_password = "SQLisBetterThanDynamoForOurIdentifiersDB"

grafana_admin_password = "GY2VdmpuN8SwhXNs"

es_cluster_credentials = {
  name     = "0dc47430ad577586772707be80a3763c"
  region   = "eu-west-1"
  port     = "9243"
  username = "api"
  password = "Zexkri69IxI0gPzsBHTZVzwd"
  protocol = "https"
}

es_cluster_credentials_v6 = {
  name     = "698bff100fe5403083f64b3de030fd14"
  region   = "eu-west-1"
  port     = "9243"
  username = "elastic"
  password = "IVP2I94GA0s7mYlM2Z2rnM2S"
  protocol = "https"
}

# Configured at https://wellcome.slack.com/apps/A0F7XDUAZ-incoming-webhooks
#
# The critical hook is for posting to the #digital-platform channel, whereas
# the non-critical hook posts to #platform-alterations.
critical_slack_webhook = "https://hooks.slack.com/services/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"

non_critical_slack_webhook = "https://hooks.slack.com/services/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"

bitly_access_token = "5eee687ea86606b389f447da5b2ef83c79caf68f"

dashboard_assumable_roles = [
  "arn:aws:iam::130871440101:role/platform-team-assume-role",
]

grafana_admin_password = "GY2VdmpuN8SwhXNs"

sierra_api_url = "https://libsys.wellcomelibrary.org/iii/sierra-api/v3"
sierra_oauth_key = "Bgk2x9MsY4YDOImfzWzRtVZ0x1Hj"
sierra_oauth_secret = "aFDFfU2ZyCBMBLGgEujnnzzr"
sierra_items_fields = "updatedDate,createdDate,deletedDate,deleted,bibIds,location,status,barcode,callNumber,itemType,fixedFields,varFields"
sierra_bibs_fields = "updatedDate,createdDate,deletedDate,deleted,suppressed,available,lang,title,author,materialType,bibLevel,publishYear,catalogDate,country,orders,normTitle,normAuthor,locations,fixedFields,varFields"

# An OAuth token for accessing the GitHub API.
#
# This has the 'repo' scope for repositories in the wellcomelibrary and
# wellcometrust accounts.
#
github_api_token = "e4299902614d9bc8dc56db8e10e146cb682ade2a"

# Credentials for publishing packages to PyPI.
pypi_username = "wellcomedigitalplatform"
pypi_password = "zv4GkXrwq86kgN6349R7"


# Reporting
reporting_kibana_domain_name = "c783b93d8b0b4b11900b5793cb2a1865.eu-west-1.aws.found.io"
reporting_es_url = "https://d3f9c38fe7134d44b3ec7752d86b5e98.eu-west-1.aws.found.io:9243"
reporting_es_user = "lambda_worker"
reporting_es_pass = "367616e0643054cb8fa8f0170f4f893c"

# Bagger
bagger_mets_bucket_name = "wellcomecollection-assets-workingstorage"
bagger_read_mets_from_fileshare = "False"
bagger_working_directory = "/tmp/_bagger"
bagger_drop_bucket_name = "temp-bagit-drop-test"
bagger_drop_bucket_name_mets_only = "temp-bagit-drop-test-mets-only"
bagger_drop_bucket_name_errors = "temp-bagit-drop-test-errors"
bagger_current_preservation_bucket = "wdl-preservica"
bagger_dlcs_source_bucket = "dlcs-storage"
# aws creds that can see Preservica as well as Platform estate
bagger_aws_access_key_id = "AKIAIKE3SDMR6HSLXUEA"
bagger_aws_secret_access_key = "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"
# DLCS config
bagger_dlcs_entry = "https://api.dlcs.io/"
bagger_dlcs_api_key = "dc96ab5e-d8c3-4b34-befa-0b335f596734"
bagger_dlcs_api_secret = "a6c8e36952ad885793c1f2221a5761e89dafdd884f6730985aaed69b95eac2d1"
bagger_dlcs_customer_id = "2"
bagger_dlcs_space = "1"
# DDS credentials
bagger_dds_api_key = "dlcs"
bagger_dds_api_secret = "1cad996fa0d4"
bagger_dds_asset_prefix = "https://wellcomelibrary.org/service/asset/"
# Archive API
api_alb_cdir_blocks = ["46.102.195.182/32", "195.143.129.132/32","34.247.238.19/32", "34.246.92.106/32", "54.77.160.31/32"]
archive_oauth_details_enc = "AQICAHguq9tj8IN8B0xlz5sR1Rbnb3M2nAzCchKKrI2EDushNQF0sPX/85gjQb/ePJqwcAVgAAABHDCCARgGCSqGSIb3DQEHBqCCAQkwggEFAgEAMIH/BgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDCFW9K4J3SnNvFct6gIBEICB0dQZ1UFaNpQD6tXDGGuJ/PJGeXfjfrZbMSoWY/raQKacc4dzJdvaFfoWrfM3qrlnBrPXOnJgRj+ePt4M9TkDClDsTC0hxpG59e5cwL2wuXGb0FrYEpRCamXJgCb6oq+vQfoctJl7SBpajm6WP0GUFrtJ6K74KFa+wf/kyfOiN21rQFlVr0l+4qrA05O65jjR9c660HQi6lNH0SoBTUSwGVrRacloh3Ckd0DBoOEAjzOYMEKZpeqnHmhUN+YevwoIl4B9yl6FzxeZTEKP6YQMKmIv"

release_ids = {
  api                       = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  archive_api               = "1dbd3e58f9dd6ea91d03d81a30b92f1f97548fc4"
  archiver                  = "d9d5cf764aa18f50b51eeb0c59b0758f563f224f"
  archivist                 = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  bag_replicator            = "f754ca652e36ca33debdfc9984c5285df40f1f7a"
  bagger                    = "b8b87cb83af03ea088d5ace84b9e93df1687545d"
  cache_cleaner             = "f44b491a5d5c5ed6cac9e31efc885afca3238975"
  callback_stub_server      = "7cbeb4c48b4762919d52ae47fbaef4edbd165c9c"
  calm_adapter              = "0.0.1-7f5ac7ce9b2c85288990c5cc53d5fb2f7ef996aa_prod"
  elasticdump               = "c94babab8ad869330686e1c7e5d53455d3bd9862"
  elasticsearch_cleaner     = "d50e3f3854df5b7089ec0d7f5c02e398141e560c"
  example_app               = "9cda22eecfb9ac9866b25a856e51130d915fbe0b"
  gatling                   = "357922f8358ef84081d53715cb70ea934ad739df"
  goobi_reader              = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  id_minter                 = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  ingestor                  = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  loris                     = "2c752aa7d1208b7ec9d1538d3a88fe5662f2ac4c"
  matcher                   = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  merger                    = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  miro_adapter              = "1a469def80ca8bb40b36e01cfb32232dff6c0b93"
  nginx_api                 = "4d0b58c7cd5feefbe77637f7fcda0d93b645e11b"
  nginx_api-delta           = "3dd8a423123e1d175dd44520fcf03435a5fc92c8"
  nginx_api-gw              = "bad0dbfa548874938d16496e313b05adb71268b7"
  nginx_grafana             = "72ffd8713270c69ce75f52937daa9e6395cc4c57"
  nginx_loris               = "a3786251af89eaf68dc41026e23f09e85d01702f"
  nginx_loris-delta         = "ec29397c3396aa34cceb62e8d353d7aab731e1af"
  nginx_services            = "6f1be35c424d405691d7246dbf999ed7c101833a"
  notifier                  = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  palette_api               = "a0455870f616533be3d571fdd5e0e839e5ff667a"
  progress                  = "289cf1162139950e1cd6f62986b4e725aec0f72e"
  progress_async            = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  progress_http             = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  recorder                  = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  registrar                 = "b977afe9ba08f212b9e65220872bb0dde7793f90"
  registrar_async           = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  registrar_http            = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  reindex_request_creator   = "e239fcf50870f90baadb019d1023bd8d7e027bbb"
  reindex_request_processor = "2223d8086672420f91220f899a6c793b756bcce4"
  reindex_worker            = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  reindexer                 = "42b68c793fe6d87029226da8298462d7db34581d"
  sierra_adapter            = "d0011196848872a9a5f284f30f19946b7543f004"
  sierra_bib_merger         = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  sierra_bibs_to_dynamo     = "0b45d5ff677fbe339a1cca1690a162540ecec06f"
  sierra_item_merger        = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  sierra_items_to_dynamo    = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  sierra_reader             = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  sierra_to_dynamo          = "1de724ea9b9e4d300f4505e103406ed5938b45b1_prod"
  slack_budget_bot          = "6a0141109bbfda0380aeeb0223b161b291533631"
  snapshot_convertor        = "d23ed8c4e91cbeab61666f9f9c1290c7421d635b"
  snapshot_generator        = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  spot_termination_watcher  = "1603b24acde4f3327766b4a564a805c6b8f56597"
  sqs_freezeray             = "50c65d2f893c962370015c55f8f423896380d532"
  sqs_redrive               = "50c65d2f893c962370015c55f8f423896380d532"
  tandem_vault_enrichment   = "db0627fc5213589faf8d5634a0f948f65c70c133"
  tandem_vault_uploader     = "db0627fc5213589faf8d5634a0f948f65c70c133"
  tif-metadata              = "d96708192cedf76c1cb492d52d21a9b6e7901814"
  transformer               = "b00079ffa5ea6ce8d28674007ed48fc98bc3f01e"
  transformer_miro          = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  transformer_sierra        = "b1c791dec7761021307a69e5fe98a7f00a17c935"
  update_api_docs           = "61e8e94d9e1d4baaf1ac9cbe789e9112856f76a5"
  xml_to_json_converter     = "db0627fc5213589faf8d5634a0f948f65c70c133"
}
