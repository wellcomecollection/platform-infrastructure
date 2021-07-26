import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
import { getCreds } from "@weco/ts-aws/sts";
import { URLSearchParams } from "url";
import { KibanaClient } from "./kibana";

/**
 * Most the work here is based on the Kibana alerting and action APIs
 * see:
 * - https://www.elastic.co/guide/en/kibana/master/alerting-apis.html
 * - https://www.elastic.co/guide/en/kibana/current/actions-and-connectors-api.html
 *
 */

type ElasticError = { statusCode: number };

type ConnectorType = ".server-log" | ".slack";

type KibanaList<T = Record<string, unknown>> = {
  page: number;
  total: number;
  per_page: number;
  data: T[];
};

type Action = {
  group: string;
  id: string;
  params: { level: string; message: string };
  connector_type_id: ConnectorType;
};

type Rule = {
  id: string;
  enabled: boolean;
  tags: string[];
  params: Record<string, unknown>;
  consumer: string;
  name: string;
  throttle: string;
  schedule: Record<string, unknown>;
  rule_type_id: string;
  created_by: string;
  updated_by: string;
  created_at: string;
  updated_at: string;
  api_key_owner: string;
  notify_when: string;
  mute_all: string;
  muted_alert_ids: string;
  scheduled_task_id: string;
  execution_status: string;
  actions: Action[];
};

type Connector = {
  id: string;
  connector_type_id: ConnectorType;
  name: string;
};

async function getSlackConnector(
  kibanaClient: KibanaClient,
  slackWebhook: string
): Promise<Connector> {
  // find/put slack connector
  // Annoyingly - we should be able to do this with `xpack.actions.preconfigured`
  // but it's not available on EC yet.
  // see:  https://www.elastic.co/guide/en/kibana/current/alert-action-settings-kb.html
  const slackConnector = {
    connector_type_id: ".slack",
    name: "Slack: #wc-platform-alerts",
  };

  const connectors = await kibanaClient.send<Connector[]>("actions/connectors");

  const ecSlackConnector = connectors.find(
    ({ connector_type_id, name }) =>
      connector_type_id === slackConnector.connector_type_id &&
      name === slackConnector.name
  );

  if (ecSlackConnector) {
    console.info(`${slackConnector.name} exists`);
    return ecSlackConnector;
  }

  console.info(`${slackConnector.name} missing, creating...`);
  const createConnectorRes = await kibanaClient.send<Connector>(
    "actions/connector",
    {
      method: "POST",
      body: JSON.stringify({
        ...slackConnector,
        secrets: {
          webhookUrl: slackWebhook,
        },
      }),
    }
  );

  return createConnectorRes;
}

async function getAlertingRules(
  kibanaClient: KibanaClient,
  search: string
): Promise<Rule[]> {
  const qs = new URLSearchParams({
    search,
  });

  const rules = await kibanaClient.send<KibanaList<Rule>>(
    `alerting/rules/_find?${qs.toString()}`
  );

  return rules.data;
}

async function run() {
  // We use developer over read_only as we need to read secrets
  const creds = await getCreds("platform", "developer");
  const secretsManagerClient = new SecretsManagerClient({
    region: "eu-west-1",
    credentials: creds,
  });
  const [username, password, endpoint, slackWebhook] = await Promise.all(
    [
      "elasticsearch/logging/management_username",
      "elasticsearch/logging/management_password",
      "elasticsearch/logging/kibana_endpoint",
      "monitoring/critical_slack_webhook",
    ].map(async (secretId) => {
      const { SecretString: secret } = await secretsManagerClient.send(
        new GetSecretValueCommand({ SecretId: secretId })
      );
      return secret;
    })
  );

  const kibanaClient = new KibanaClient(username!, password!, endpoint!);

  const connector = await getSlackConnector(kibanaClient, slackWebhook!);

  const rules = await getAlertingRules(
    kibanaClient,
    "monitoring_ccr_read_exceptions"
  );
  if (rules.length === 0)
    throw Error("Found 0 rules for `monitoring_ccr_read_exceptions`");
  if (rules.length > 1)
    throw Error(
      "Found ${rules.length} rules for `monitoring_ccr_read_exceptions`. We need exactly 1."
    );

  const rule = rules[0];

  // Check for a connection
  const connection = rule.actions.find((action) => action.id === connector.id);
  if (connection) {
    console.info(
      `${connector.name}:${connector.connector_type_id} connection exists, all good`
    );
    process.exit(0);
  }

  if (!connection) {
    console.info(
      `${connector.name}:${connector.connector_type_id} connection missing, creating...`
    );

    const updatedRule = {
      throttle: rule.throttle,
      name: rule.name,
      tags: rule.tags,
      schedule: rule.schedule,
      params: rule.params,
      notify_when: rule.notify_when,
      actions: [
        ...rule.actions.map((rule) => ({
          ...rule,
          connector_type_id: undefined,
        })),
        {
          id: connector.id,
          group: "default",
          params: {
            message: "{{context.internalShortMessage}}",
          },
        },
      ],
    };

    const updatedRuleRes = await kibanaClient.send<Rule | ElasticError>(
      `alerting/rule/${rule.id}`,
      {
        method: "PUT",
        body: JSON.stringify(updatedRule),
      }
    );

    if (updatedRuleRes) {
      console.info(`updated rule ${rule.id} to have action ${connector.name}`);
      process.exit(0);
    } else {
      console.error(
        `Error. Couldn't update rule ${rule.id} to have action ${connector.name}`,
        updatedRuleRes
      );
      process.exit(1);
    }
  }
}

run();
