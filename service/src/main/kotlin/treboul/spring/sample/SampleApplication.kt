package treboul.spring.sample

import kotlinx.coroutines.reactor.awaitSingle
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.web.reactive.function.BodyInserters
import org.springframework.web.reactive.function.server.ServerRequest
import org.springframework.web.reactive.function.server.ServerResponse
import org.springframework.web.reactive.function.server.ServerResponse.ok
import org.springframework.web.reactive.function.server.coRouter

@SpringBootApplication
@EnableConfigurationProperties(SampleProperties::class)
class SampleApplication {
    private val requestHandler: SampleRequestHandler = SampleRequestHandler()


    @Bean
    fun router(properties: SampleProperties) = coRouter {
        GET("/") { requestHandler.handleIndex(it, properties) }
        GET("/{*path}") { requestHandler.handle(it, properties) }
        PUT("/{*path}") { requestHandler.handle(it, properties) }
        POST("/{*path}") { requestHandler.handle(it, properties) }
        DELETE("/{*path}") { requestHandler.handle(it, properties) }
    }
}

class SampleRequestHandler {
    private val log = LoggerFactory.getLogger(SampleRequestHandler::class.java)

    suspend fun handle(request: ServerRequest, properties: SampleProperties): ServerResponse {
        val title = "HTTP ${request.method().name()} ${request.path()}"
        log.info(title)
        return ok()
            .body(
                BodyInserters.fromValue(
                    """
                    |$title
                    |${headersToString(request.headers())}
                    |${properties.config.key}: ${properties.config.value}
                    |${properties.secret.key}: ${properties.secret.value}
                    |""".trimMargin()
                )
            )
            .awaitSingle()
    }

    suspend fun handleIndex(request: ServerRequest, properties: SampleProperties): ServerResponse {
        val title = "HTTP(index) ${request.method().name()} ${request.path()}"
        log.info(title)
        return ok()
            .headers { it.set("Content-Type", "text/html") }
            .body(
                BodyInserters.fromValue(
                    """
                    |<!DOCTYPE html>
                    |<html lang="en">
                    |<head>
                    |    <meta charset="UTF-8">
                    |    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    |    <title>Centered Page</title>
                    |    <style>
                    |        body {
                    |            margin: 0;
                    |            display: flex;
                    |            align-items: center;
                    |            justify-content: center;
                    |            height: 100vh;
                    |        }
                    |        .center-box {
                    |            text-align: center;
                    |            padding: 20px;
                    |            border: 1px solid #ccc;
                    |            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                    |        }
                    |    </style>
                    |</head>
                    |<body style="background-color:${properties.htmlBackgroundColor};">
                    |  <div class="center-box">
                    |    <h1>Configured color - ${properties.htmlBackgroundColor}</h1>
                    |    <p>${properties.config.key} - ${properties.config.value}</p>
                    |    <p>${properties.secret.key} - ${properties.secret.value}</p>
                    |  </div>  
                    |</body>
                    |</html>
                    |""".trimMargin()
                )
            )
            .awaitSingle()
    }

    private fun headersToString(headers: ServerRequest.Headers): String {
        val httpHeaders = headers.asHttpHeaders()
        return httpHeaders.keys
            .fold("") { acc, key ->
                "$acc$key: ${httpHeaders.get(key)}\n"
            }
    }
}

fun main(args: Array<String>) {
    runApplication<SampleApplication>(*args)
}
