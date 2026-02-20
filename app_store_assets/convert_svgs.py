#!/usr/bin/env python3
"""
Convert SVG mockups to PNG for app store submission.
Requires: cairosvg (install via: pip install cairosvg)
"""

import os
import sys
import subprocess

# Target sizes for app store screenshots
TARGET_SIZES = {
    # iOS iPhone
    'iphone_6.5': (1242, 2688),      # iPhone 14 Pro Max
    'iphone_5.5': (1242, 2208),      # iPhone 8 Plus
    # iOS iPad  
    'ipad_12.9': (2048, 2732),       # iPad Pro 12.9"
    'ipad_11': (1668, 2388),         # iPad Air 11"
    # Android
    'android_phone': (1080, 1920),   # Full HD phone
    'android_tablet_7': (1200, 1920), # 7" tablet
    'android_tablet_10': (1600, 2560), # 10" tablet
}

def check_dependencies():
    """Check if cairosvg is available."""
    try:
        import cairosvg
        return True
    except ImportError:
        print("❌ cairosvg not found. Install with: pip install cairosvg")
        return False

def convert_svg_to_png(svg_path, png_path, width, height):
    """Convert SVG to PNG using cairosvg."""
    try:
        import cairosvg
        cairosvg.svg2png(
            url=svg_path,
            write_to=png_path,
            output_width=width,
            output_height=height
        )
        print(f"  ✅ Converted: {os.path.basename(svg_path)} → {os.path.basename(png_path)} ({width}x{height})")
        return True
    except Exception as e:
        print(f"  ❌ Failed to convert {svg_path}: {e}")
        return False

def main():
    print("📱 Cross App Store Screenshot Generator")
    print("=" * 50)
    
    # Check dependencies
    if not check_dependencies():
        print("\n📝 Alternative conversion methods:")
        print("1. Online converter: https://svgtopng.com/")
        print("2. Install Inkscape: brew install inkscape")
        print("3. Install ImageMagick: brew install imagemagick")
        sys.exit(1)
    
    # Get all SVG files in current directory
    svg_files = [f for f in os.listdir('.') if f.endswith('.svg')]
    
    if not svg_files:
        print("❌ No SVG files found in current directory.")
        print("   Run this script from the app_store_assets directory.")
        sys.exit(1)
    
    print(f"\n📂 Found {len(svg_files)} SVG files:")
    for svg in svg_files:
        print(f"  • {svg}")
    
    # Create output directories
    for size_name in TARGET_SIZES.keys():
        os.makedirs(f"output/{size_name}", exist_ok=True)
    
    print("\n🔄 Converting SVGs to PNGs...")
    
    total_conversions = 0
    for svg_file in svg_files:
        basename = os.path.splitext(svg_file)[0]
        
        for size_name, (width, height) in TARGET_SIZES.items():
            png_file = f"output/{size_name}/{basename}.png"
            
            if convert_svg_to_png(svg_file, png_file, width, height):
                total_conversions += 1
    
    print(f"\n🎉 Done! Converted {total_conversions} images.")
    print(f"\n📁 Output structure:")
    for size_name in TARGET_SIZES.keys():
        print(f"  output/{size_name}/")
        print(f"    ├── dashboard.png")
        print(f"    ├── active_workout.png")
        print(f"    └── ...")
    
    print("\n📋 Next steps:")
    print("1. Add device frames using online tools:")
    print("   • https://appstorescreenshot.com/")
    print("   • https://mockuphone.com/")
    print("2. Create feature graphic (1024×500)")
    print("3. Write app store descriptions")
    print("4. Submit to App Store Connect / Google Play Console")

if __name__ == "__main__":
    main()