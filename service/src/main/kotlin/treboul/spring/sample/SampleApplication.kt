package treboul.spring.sample

import kotlinx.coroutines.reactor.awaitSingle
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
        GET("/{*path}") { requestHandler.handle(it, properties) }
        PUT("/{*path}") { requestHandler.handle(it, properties) }
        POST("/{*path}") { requestHandler.handle(it, properties) }
        DELETE("/{*path}") { requestHandler.handle(it, properties) }
    }
}

class SampleRequestHandler {
    suspend fun handle(request: ServerRequest, properties: SampleProperties): ServerResponse {
        val title = "HTTP ${request.method().name()} ${request.path()}"
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
