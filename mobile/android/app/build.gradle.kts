import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Ключ подписи в репозитории не хранится. Локально путь и пароли берутся из
// android/key.properties (он в .gitignore), в CI — из переменных окружения,
// куда их кладёт шаг с секретами. Нет ни того, ни другого — собираем отладочной
// подписью, чтобы `flutter run --release` работал на машине без ключа.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

fun signingValue(property: String, env: String): String? =
    keystoreProperties.getProperty(property) ?: System.getenv(env)

val releaseStorePath = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
val hasReleaseKey = releaseStorePath != null && file(releaseStorePath).exists()

android {
    namespace = "io.github.ahatovemil.interviewtrainer"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion намеренно не задан: нативного кода в проекте нет, ни один плагин
    // не собирает C/C++. С этой строкой AGP тянет NDK на гигабайт при каждой сборке.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Идентификатор неизменяем после первой публикации в магазине.
        applicationId = "io.github.ahatovemil.interviewtrainer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(releaseStorePath!!)
                storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // Осознанный запасной вариант для локальной сборки. В магазин
                // такой артефакт не примут — там проверяется подпись.
                logger.warn("Ключ подписи не найден, собираем отладочной подписью")
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
