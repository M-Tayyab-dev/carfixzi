allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // file_picker 8.3.7 hardcodes API 34, but its lifecycle dependency requires API 36.
    if (name == "file_picker") {
        pluginManager.withPlugin("com.android.library") {
            extensions.getByName("androidComponents").withGroovyBuilder {
                "finalizeDsl"(Action<Any> {
                    withGroovyBuilder { setProperty("compileSdk", 36) }
                })
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
