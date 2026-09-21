pluginManagement {
    val localMavenRepository = file("offline-maven")
    val offlineMavenOnly = providers.gradleProperty("offlineMavenOnly").orNull == "true"
    val skipOfflineMaven = providers.gradleProperty("skipOfflineMaven").orNull == "true"

    repositories {
        if (!skipOfflineMaven) {
            maven {
                name = "projectOfflineMaven"
                url = uri(localMavenRepository)
                metadataSources {
                    gradleMetadata()
                    mavenPom()
                    artifact()
                }
            }
        }
        if (offlineMavenOnly) return@repositories

        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                "com.android.application" -> {
                    useModule("com.android.tools.build:gradle:${requested.version}")
                }
                "org.jetbrains.kotlin.plugin.compose" -> {
                    useModule("org.jetbrains.kotlin:compose-compiler-gradle-plugin:${requested.version}")
                }
            }
        }
    }
}
dependencyResolutionManagement {
    val localMavenRepository = file("offline-maven")
    val offlineMavenOnly = providers.gradleProperty("offlineMavenOnly").orNull == "true"
    val skipOfflineMaven = providers.gradleProperty("skipOfflineMaven").orNull == "true"

    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        if (!skipOfflineMaven) {
            maven {
                name = "projectOfflineMaven"
                url = uri(localMavenRepository)
                metadataSources {
                    gradleMetadata()
                    mavenPom()
                    artifact()
                }
            }
        }
        if (offlineMavenOnly) return@repositories

        google()
        mavenCentral()
    }
}

rootProject.name = "test"
include(":app")
