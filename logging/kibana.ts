import fetch, { RequestInit } from "node-fetch";

class KibanaClient {
  #username: string;
  #password: string;
  #endpoint: string;

  constructor(username: string, password: string, endpoint: string) {
    this.#username = username;
    this.#password = password;
    this.#endpoint = endpoint;
  }

  async send<T = unknown>(path: string, opts?: RequestInit) {
    const apiUrl = `https://${this.#username}:${this.#password}@${
      this.#endpoint
    }:9243/api/${path}`;
    const json = await fetch(apiUrl, {
      headers: {
        "kbn-xsrf": "true",
        "Content-Type": "application/json",
      },
      ...(opts ?? {}),
    }).then((res) => res.json());
    return json as T;
  }
}

export { KibanaClient };
