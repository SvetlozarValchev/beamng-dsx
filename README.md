# BeamNG DualSense Adaptive Triggers Mod

A mod that adds PS5 DualSense adaptive triggers support to BeamNG.drive.

## Features

- Progressive brake feedback
- ABS feedback
- Increased spring effect on the throttle

## Prerequisites

This mod requires DualSenseX (DSX):
- Download from: https://github.com/Paliverse/DualSenseX/releases
- Alternatively, consider getting the paid Steam version for:
  - Better UX
  - HidHide driver (for hiding PS controller in games)
  - Support for the developer
  - Access to potential future exclusive features

## Installation

1. Install DSX (either free DSX v1 or paid Steam version DSX v2)
2. Start DSX
3. Connect your PS5 controller (via bluetooth or USB)
4. Enable 'Xbox 360 emulation' in DSX
5. Start BeamNG
6. Enjoy!

## Configuration

You can customize the mod settings by editing `/lua/config.lua`

## Linux Support

Thanks to ASOwnerYT, there's an experimental Linux-compatible Python script available at: https://github.com/ASOwnerYT/pydualsensex

Note: This is experimental and hasn't been personally tested by the mod developer.

## Troubleshooting

### Adaptive Triggers Not Working

1. **Check if DSX is Running**
   - The mod cannot function without DSX
   - Verify controller connection status in DSX

2. **Controller Connection**
   - If 'controller connected' shows red, the issue might be with PC/DSX controller recognition
   - This may require case-by-case troubleshooting

3. **UDP Configuration**
   - Ensure UDP light is green (DSX v2 only)
   - Verify UDP is enabled in settings
   - Port should be set to 6969

4. **Mod Status**
   - Check for mod crashes by opening the dev console ('~' key)
   - If you see red text, please share the screenshot/log

5. **Firewall Settings**
   - Try enabling port 6969 through your Firewall/Antivirus
   - Usually unnecessary as local connections are typically allowed

### Double Controller Detection

If the game detects the controller twice (duplicate button triggers), try these solutions:

1. **Verify Xbox 360 Emulation**
   - Ensure Controller Emulation is set to 'Xbox 360' in DSX

2. **Connection Mode**
   - DSX v1: Use controller only in Bluetooth mode
   - DSX v2: Avoid using both wired and Bluetooth simultaneously

3. **Driver Management**
   - DSX v2 users: Try reinstalling the HidHide driver

4. **Steam Configuration**
   - Disable Steam's PlayStation controller recognition
   - The controller should only be recognized through Xbox 360 emulation

## Planned Features

- UI Widget for configuration and information
- Improved UDP connection status feedback
- Fine-tuned adaptive trigger feel
- Per-car customization of adaptive triggers
- Controller LED effects (RPM limiter, Sirens, etc.)
- Future possibility: Haptic Feedback for collisions (pending DSX v3 UDP support)

## Note on Trigger Feel

The adaptive trigger feel is still being refined. Your patience and feedback are appreciated.
