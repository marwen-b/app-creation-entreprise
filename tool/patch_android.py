"""Adapte le projet Android généré par `flutter create` aux besoins de l'application.

Lancé automatiquement par GitHub Actions après la génération du dossier android/.
- active la « desugaring » Java exigée par flutter_local_notifications ;
- ajoute les règles R8 utiles aux notifications programmées ;
- déclare les permissions et récepteurs des rappels, le nom affiché et l'ouverture des liens web.
"""
import re
import sys
from pathlib import Path

APP_LABEL = "Nebda"
ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "android" / "app"


def patch_gradle():
    kts = APP / "build.gradle.kts"
    groovy = APP / "build.gradle"
    path = kts if kts.exists() else groovy
    g = path.read_text()
    is_kts = path.suffix == ".kts"

    if "oreLibraryDesugaringEnabled" not in g:
        flag = "isCoreLibraryDesugaringEnabled = true" if is_kts else "coreLibraryDesugaringEnabled = true"
        g, n = re.subn(r"compileOptions\s*\{", "compileOptions {\n        " + flag, g, count=1)
        if n == 0:
            sys.exit("compileOptions introuvable dans " + path.name)
        dep = ('coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")' if is_kts
               else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'")
        g += "\ndependencies {\n    " + dep + "\n}\n"

    if "proguard-rules.pro" not in g:
        rule = ('proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")' if is_kts
                else "proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'")
        g, n = re.subn(r"(release\s*\{)", r"\1\n            " + rule.replace("\\", "\\\\"), g, count=1)
        if n == 0:
            print("Avertissement : bloc release introuvable, règles R8 non ajoutées")

    path.write_text(g)
    (APP / "proguard-rules.pro").write_text(
        "-keep class com.dexterous.** { *; }\n"
        "-keep class com.google.gson.reflect.TypeToken\n"
        "-keep class * extends com.google.gson.reflect.TypeToken\n"
        "-keep public class * implements java.lang.reflect.Type\n"
        "-keepattributes Signature\n"
    )
    print("Gradle :", path.name, "adapté")


def patch_manifest():
    path = APP / "src" / "main" / "AndroidManifest.xml"
    m = path.read_text()

    m = re.sub(r'android:label="[^"]*"', f'android:label="{APP_LABEL}"', m, count=1)

    perms = [
        "android.permission.POST_NOTIFICATIONS",
        "android.permission.RECEIVE_BOOT_COMPLETED",
        "android.permission.VIBRATE",
    ]
    block = "".join(f'    <uses-permission android:name="{p}"/>\n' for p in perms if p not in m)
    if block:
        m = re.sub(r"(<manifest[^>]*>\n?)", r"\1" + block, m, count=1)

    if "ScheduledNotificationReceiver" not in m:
        receivers = (
            '        <receiver android:exported="false" '
            'android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />\n'
            '        <receiver android:exported="false" '
            'android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">\n'
            '            <intent-filter>\n'
            '                <action android:name="android.intent.action.BOOT_COMPLETED"/>\n'
            '                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>\n'
            '                <action android:name="android.intent.action.QUICKBOOT_POWERON" />\n'
            '                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>\n'
            '            </intent-filter>\n'
            '        </receiver>\n'
        )
        m = m.replace("</application>", receivers + "    </application>", 1)

    if 'android:scheme="https"' not in m:
        intent = (
            '        <intent>\n'
            '            <action android:name="android.intent.action.VIEW" />\n'
            '            <data android:scheme="https" />\n'
            '        </intent>\n'
        )
        if "<queries>" in m:
            m = m.replace("<queries>", "<queries>\n" + intent, 1)
        else:
            m = m.replace("</manifest>", "    <queries>\n" + intent + "    </queries>\n</manifest>", 1)

    path.write_text(m)
    print("Manifeste adapté")


if __name__ == "__main__":
    patch_gradle()
    patch_manifest()
