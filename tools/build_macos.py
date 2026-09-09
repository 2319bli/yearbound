#!/usr/bin/env python3
"""Build a self-contained Apple silicon development app using an installed Godot."""
import os, pathlib, plistlib, shutil, subprocess, tempfile, struct
project=pathlib.Path(__file__).resolve().parents[1]
godot=pathlib.Path(os.environ.get('GODOT_BIN','/Applications/Godot.app/Contents/MacOS/Godot'))
app=project.parent/'Yearbound.app'; mac=app/'Contents/MacOS'; resources=app/'Contents/Resources'
mac.mkdir(parents=True,exist_ok=True); resources.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='yearbound-build-') as scratch:
 scratch=pathlib.Path(scratch)
 def godot_run(*args,env=None):
  subprocess.run([str(godot),'--headless','--path',str(project),'--log-file',str(scratch/'godot.log'),*args],check=True,env=env)
 godot_run('--editor','--import','--quit')
 godot_run('--export-pack','macOS',str(resources/'Yearbound.pck'))
 env=os.environ.copy();env['YEARBOUND_CAPTURE_DIR']=str(scratch)
 godot_run('--script','tests/icon.gd',env=env)
 icons=scratch/'Yearbound.iconset';icons.mkdir()
 for size in [16,32,128,256,512]:
  for scale in [1,2]:
   name=f'icon_{size}x{size}'+('@2x' if scale==2 else '')+'.png'
   subprocess.run(['sips','-z',str(size*scale),str(size*scale),str(scratch/'icon.png'),'--out',str(icons/name)],check=True,stdout=subprocess.DEVNULL)
 chunks=[]
 for tag,name in [('icp4','icon_16x16.png'),('icp5','icon_32x32.png'),('icp6','icon_32x32@2x.png'),('ic07','icon_128x128.png'),('ic08','icon_256x256.png'),('ic09','icon_512x512.png'),('ic10','icon_512x512@2x.png')]:
  data=(icons/name).read_bytes();chunks.append(struct.pack('>4sI',tag.encode(),len(data)+8)+data)
 payload=b''.join(chunks)
 (resources/'Yearbound.icns').write_bytes(struct.pack('>4sI',b'icns',len(payload)+8)+payload)
 subprocess.run(['lipo',str(godot),'-thin','arm64','-output',str(mac/'YearboundRuntime')],check=True)
 launcher='''#!/bin/sh
YEARBOUND_BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$YEARBOUND_BIN_DIR/YearboundRuntime" --main-pack "$YEARBOUND_BIN_DIR/../Resources/Yearbound.pck" "$@"
'''
 (mac/'Yearbound').write_text(launcher)
 for name in ['Yearbound','YearboundRuntime']:(mac/name).chmod(0o755)
 info={'CFBundleName':'Yearbound','CFBundleDisplayName':'Yearbound','CFBundleIdentifier':'games.yearbound.foundation','CFBundleVersion':'0.14.0','CFBundleShortVersionString':'0.14.0','CFBundlePackageType':'APPL','CFBundleExecutable':'Yearbound','CFBundleIconFile':'Yearbound.icns','NSHighResolutionCapable':True,'LSMinimumSystemVersion':'12.0'}
 with (app/'Contents/Info.plist').open('wb') as f:plistlib.dump(info,f)
 shutil.copy2(project/'docs/GODOT_LICENSE.txt',resources/'GODOT_LICENSE.txt')
 shutil.copy2(project/'docs/ENGINE_NOTICES.txt',resources/'ENGINE_NOTICES.txt')
 subprocess.run(['codesign','--force','--sign','-','--timestamp=none',str(mac/'YearboundRuntime')],check=True)
 subprocess.run(['codesign','--force','--deep','--sign','-','--timestamp=none',str(app)],check=True)
 subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True)
 print('Built',app)
