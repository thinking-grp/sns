buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")  // 最新の安定版に変更
        classpath("com.android.tools.build:gradle:7.0.4")  // 必要に応じて更新
        classpath("com.google.gms:google-services:4.3.15") // 追加
        
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
//    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
