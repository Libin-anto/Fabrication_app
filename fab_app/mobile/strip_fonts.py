import os
import glob
import re

screens_dir = r"c:\Users\Libin\PROJECT\Meerash\fab_app\mobile\src\screens"
screens = glob.glob(os.path.join(screens_dir, "*.tsx"))

imports_pattern = re.compile(
    r"import \{ useFonts \} from 'expo-font';\n"
    r"import \{ Oswald_700Bold \} from '@expo-google-fonts/oswald';\n"
    r"import \{ Inter_400Regular, Inter_500Medium \} from '@expo-google-fonts/inter';\n"
    r"import \{ IBMPlexMono_400Regular \} from '@expo-google-fonts/ibm-plex-mono';\n"
)

hook_pattern = re.compile(
    r"\s*const \[fontsLoaded\] = useFonts\(\{\n"
    r"\s*Oswald_700Bold,\n"
    r"\s*Inter_400Regular,\n"
    r"\s*Inter_500Medium,\n"
    r"\s*IBMPlexMono_400Regular,\n"
    r"\s*\}\);\n\n"
    r"\s*if \(\!fontsLoaded\) \{\n"
    r"\s*return \(\n"
    r"\s*<View style=\{\[styles\.container, styles\.centerAll\]\}>\n"
    r"\s*<ActivityIndicator size=\"large\" color=\"#F2A71B\" />\n"
    r"\s*</View>\n"
    r"\s*\);\n"
    r"\s*\}\n"
)

# ActivityIndicator import might be removed if unused, but we'll leave it to avoid missing other uses (like the new fetching states).

for screen in screens:
    with open(screen, "r", encoding="utf-8") as f:
        content = f.read()
    
    new_content = imports_pattern.sub("", content)
    new_content = hook_pattern.sub("", new_content)
    
    with open(screen, "w", encoding="utf-8") as f:
        f.write(new_content)
    
    print(f"Processed {os.path.basename(screen)}")
