import { fastify } from "fastify";
import { fastifyConnectPlugin } from "@connectrpc/connect-fastify";

import type { ConnectRouter } from "@connectrpc/connect";
import { ElizaService } from "../gen/eliza_connect";

const routes = function (router: ConnectRouter) {
    return router.service(ElizaService, {
        async say(req) {
            return {
                sentence: `You said: ${req.sentence}`
            }
        },
    });
}

export async function listen(port: string) {
    const server = fastify({
        http2: true,
        logger: {
            level: "debug",
        },
    });
    server.register(fastifyConnectPlugin, { routes });

    await server.listen({ port: parseInt(port), host: "::" });
    console.log("server is listening at", server.addresses());
}

listen(process.env.PORT!);