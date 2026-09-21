pluginManagement {
    val localMavenRepository = file("offline-maven")
    val offlineMavenOnly = providers.gradleProperty("offlineMavenOnly").orNull == "true"

    repositories {
        maven {
            name = "projectOfflineMaven"
            url = uri(localMavenRepository)
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
}
dependencyResolutionManagement {
    val localMavenRepository = file("offline-maven")
    val offlineMavenOnly = providers.gradleProperty("offlineMavenOnly").orNull == "true"

    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven {
            name = "projectOfflineMaven"
            url = uri(localMavenRepository)
        }
        if (offlineMavenOnly) return@repositories

        google()
        mavenCentral()
    }
}

rootProject.name = "test"
include(":app")
