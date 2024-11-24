package treboul.spring.sample

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "sample")
data class SampleProperties(
    val config: SampleKeyValue,
    val secret: SampleKeyValue,
)

data class SampleKeyValue(
    var key: String,
    var value: String,
)