import path from "path";
import fs from "fs";
import axios from "axios";
import chalk from "chalk";

async function testRedirects() {
    const existingRedirects = {
        'http://www.example.com': 'http://www.example.com/',
        'http://www.example.com/f': 'http://www.example.com'

    } as Record<string, string>;

    Object.entries(existingRedirects).map(
        (async ([from, to]) => {
            const axiosResponse = await axios.get(from);
            const responseUrl = axiosResponse.request.res.responseUrl;
            if (responseUrl === to) {
                console.info(chalk.green(`✓ ${from} redirected successfully`));
            } else {
                console.error(
                    chalk.redBright(`✘ ${from} NOT redirected!`),
                    chalk.red(`${responseUrl} != ${to}`)
                );
            }
        }
    );
}

testRedirects();