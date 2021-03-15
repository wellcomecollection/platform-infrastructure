import axios, {AxiosRequestConfig, AxiosResponse} from "axios";

export async function safeGet<T>(url: string, config?: AxiosRequestConfig): Promise<Error | T> {
    const apiResult: AxiosResponse<any> | Error = await axios.get(url, config).catch((error) => {
        // Log underlying error here, we don't want to expose it to callers.
        console.error(error)

        if (error.response) {
            return Error(`Got ${error.response.status} from ${url}`)
        } else if (error.request) {
            return Error(`No response from ${url}`)
        }

        return Error(`Unknown error from ${url}: ${error}`)
    });

    if(apiResult instanceof Error) {
        return apiResult;
    }

    return apiResult.data
}