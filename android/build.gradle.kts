buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.android.tools.build:gradle:8.7.3")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    buildscript {
        repositories {
            google()
            mavenCentral()
        }
        dependencies {
            classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")

    // Fix for ar_flutter_plugin namespace issue and Kotlin version compatibility
    // Global workaround for plugins missing namespace (AGP 8+ requirement)
    // Global workaround for plugins missing namespace (AGP 8+ requirement)
    // Global workaround for plugins missing namespace (AGP 8+ requirement)
    val configureNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.LibraryExtension) {
                if (android.namespace == null) {
                    val safeGroup = project.group.toString().replace("-", "_")
                    val safeName = project.name.toString().replace("-", "_")
                    android.namespace = "$safeGroup.$safeName"
                    
                    // Remove package attribute from AndroidManifest.xml to avoid conflicts
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        var content = manifestFile.readText()
                        // Remove any package attribute from the manifest tag
                        if (content.contains("package=")) {
                            content = content.replace(Regex("""package\s*=\s*"[^"]*"\s*"""), "")
                            manifestFile.writeText(content)
                        }
                    }
                }
            }
        }
    }
    
    
    // Force Kotlin JVM target and Java compile options for Android projects
    val configureKotlin = {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                try {
                    android.compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_11
                        targetCompatibility = JavaVersion.VERSION_11
                    }
                } catch (e: Exception) {
                    // Already finalized, skip
                }
            }
            // Force compileSdk to 35 for library projects to fix lStar attribute issue and meet plugin requirements
            if (android is com.android.build.gradle.LibraryExtension) {
                try {
                    android.compileSdk = 35
                } catch (e: Exception) {
                    // Already finalized, skip
                }
            }
        }
        // Configure Kotlin JVM target
        project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
            kotlinOptions {
                jvmTarget = "11"
            }
        }
        // Also configure via extension if available
        project.extensions.findByType(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java)?.apply {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        }
    }

    if (!project.state.executed) {
        project.afterEvaluate {
            configureNamespace()
            configureKotlin()
        }
    } else {
        configureNamespace()
        configureKotlin()
    }

    // Force Kotlin version for all subprojects to avoid version mismatch
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-stdlib") {
                useVersion("1.9.22") 
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
