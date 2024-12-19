package treboul.quarkus.sample

import io.quarkus.runtime.Quarkus
import io.quarkus.runtime.annotations.QuarkusMain
import jakarta.ws.rs.GET
import jakarta.ws.rs.Path
import jakarta.ws.rs.Produces
import jakarta.ws.rs.core.Context
import jakarta.ws.rs.core.HttpHeaders
import jakarta.ws.rs.core.MediaType
import jakarta.ws.rs.core.Response
import jakarta.ws.rs.core.UriInfo
import java.util.LinkedHashMap
import org.eclipse.microprofile.config.ConfigProvider
import org.eclipse.microprofile.config.inject.ConfigProperty
import org.slf4j.LoggerFactory


@Path("")
class SampleApplication {
    @ConfigProperty(name = "sample.config.key")
    private lateinit var configKey: String

    @ConfigProperty(name = "sample.config.value")
    private lateinit var configValue: String

    @ConfigProperty(name = "sample.secret.key")
    private lateinit var secretKey: String

    @ConfigProperty(name = "sample.secret.key")
    private lateinit var secretValue: String

    @ConfigProperty(name = "sample.html-background-color")
    private lateinit var color: String

    private val requestHandler: SampleRequestHandler = SampleRequestHandler()

    @GET
    @Path("/all")
    @Produces(MediaType.APPLICATION_JSON)
    fun all(): Map<String, String> {
        val config = ConfigProvider.getConfig()

        val map = LinkedHashMap<String, String>()

        for (configSource in config.configSources) {
            map["################### ${configSource.name}"] = "#######################################################"
            map["${configSource.name}"] = "${configSource.ordinal}"
            map.putAll(configSource.properties)
        }

        return map
    }

    @GET
    @Produces(value = [MediaType.TEXT_PLAIN, MediaType.TEXT_HTML])
    @Path("/{path: .*}")
    fun handleRequest(@Context headers: HttpHeaders, @Context uriInfo: UriInfo): Response? {
        val properties = SampleProperties(
            SampleKeyValue(configKey, configValue),
            SampleKeyValue(secretKey, secretValue),
            color
        )
        return when (uriInfo.path) {
            "" -> requestHandler.handleIndex(properties)
            "/" -> requestHandler.handleIndex(properties)
            "/index" -> requestHandler.handleIndex(properties)
            "/index.html" -> requestHandler.handleIndex(properties)
            else -> requestHandler.handle(headers, uriInfo, properties)
        }.build()
    }
}

class SampleRequestHandler {
    private val log = LoggerFactory.getLogger(SampleRequestHandler::class.java)

    fun handle(headers: HttpHeaders, uriInfo: UriInfo, properties: SampleProperties?): Response.ResponseBuilder {
        val title = "HTTP GET ${uriInfo.path}}"
        log.info(title)
        return Response.ok()
            .header("Content-Type", "text/plain")
            .entity(
                """
                |$title
                |${headersToString(headers)}
                |${properties?.config?.key}: ${properties?.config?.value}
                |${properties?.secret?.key}: ${properties?.secret?.value}
                |""".trimMargin()
            )
    }

    private fun headersToString(headers: HttpHeaders): String {
        return headers.requestHeaders.entries
            .fold("") { acc, key ->
                "$acc${key.key}: ${key.value}\n"
            }
    }

    fun handleIndex(properties: SampleProperties): Response.ResponseBuilder {
        return Response
            .ok()
            .header("Content-Type", "text/html")
            .entity(
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
    }
}

@QuarkusMain
object Main {
    @JvmStatic
    fun main(args: Array<String>) {
        println("Running main method")
        Quarkus.run(*args)
    }
}