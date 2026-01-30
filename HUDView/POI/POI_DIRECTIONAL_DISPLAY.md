# POI Directional Display System

## Overview
The HUD now displays Points of Interest (POIs) as directional points overlaid on the live camera view. Each POI appears at its actual compass bearing relative to the camera's direction.

## How It Works

### Directional Positioning
POIs are positioned on screen based on their **bearing difference** from the camera heading:

- **Horizontal Position**: Calculated from bearing difference
  - Center of screen = 0° (camera pointing directly at POI)
  - Left edge = -30° (POI is 30° to the left)
  - Right edge = +30° (POI is 30° to the right)
  - 60° field of view total

- **Vertical Position**: Based on distance
  - Closer POIs appear at 35% from top
  - Farther POIs appear at 25% from top
  - Creates a natural "looking up" perspective

### Visual Design

Each POI marker consists of:
1. **Directional Line** - Gradient line pointing to the point
2. **Colored Point** - Circle indicating exact direction
3. **Information Label** with:
   - Icon (type-specific)
   - Name
   - Distance (meters or kilometers)
   - Population (cities) or Elevation (mountains)

### Compass Bearing View

A compass bar at the top shows:
- Cardinal directions (N, S, E, W) - bold
- Intercardinal directions (NE, SE, SW, NW) - lighter
- Red center indicator showing current view direction
- Markers scroll as you rotate the device

## User Controls

### Three Control Buttons (Bottom)
1. **Camera Rotate** (left) - Switch front/back camera
2. **List Toggle** (middle) - Show/hide nearby POI list
3. **Compass Toggle** (right) - Show/hide compass bearing bar

### Display Elements
- **Compass Bar** (top) - Shows cardinal/intercardinal directions
- **POI List** (optional, below compass) - Horizontal scroll of nearby locations
- **POI Markers** (overlay) - Directional points on camera view
- **Info Panel** (bottom) - Coordinates, heading, altitude

## Features

### Smart Filtering
- Only POIs within 60° field of view are shown
- Maximum 10 POIs displayed at once
- Distance limited to 100km
- Sorted by distance (closest first)

### Visual Feedback
- **Color coding** by type:
  - Orange: Cities
  - Brown: Mountains
  - Red: Bridges, Volcanoes
  - Blue: Water (lakes, bays, rivers)
  - Green: Parks, Forests
  - Cyan: Beaches
  - Mint: Islands

- **Distance-based opacity**:
  - < 5km: 100% opacity
  - < 20km: 90% opacity
  - < 50km: 80% opacity
  - > 50km: 70% opacity

### Real-time Updates
- POIs update as you rotate the device
- Compass bar scrolls smoothly with rotation
- Markers maintain accurate directional positioning

## Technical Details

### Bearing Calculations
```
bearing = atan2(sin(Δlon) × cos(lat2), 
                cos(lat1) × sin(lat2) - sin(lat1) × cos(lat2) × cos(Δlon))
```

### Screen Positioning
```
Horizontal: x = (bearingDiff + 30°) / 60° × screenWidth
Vertical:   y = interpolate(distance, min: 0.35h, max: 0.25h)
```

### Field of View
- Default: 60° horizontal
- Adjustable in `POIVisibilityService.visiblePOIs()`
- Matches typical smartphone camera FOV

## Data Included

### 40+ Cities
Major Northern California cities with population > 50,000

### 60+ Landmarks
- Mountains and peaks
- Bridges
- National/State parks
- Lakes and bays
- Islands
- Beaches
- Valleys

## Usage Tips

1. **Point and Sweep**: Rotate your device slowly to see different POIs
2. **Zoom In**: Get closer to see more detail
3. **Check Compass**: Use the top bar to orient yourself
4. **Toggle Views**: Hide/show elements as needed for clear AR view
5. **Read Distance**: Closer POIs are more relevant

## Performance

- Efficient filtering prevents display of off-screen POIs
- Limited to 10 simultaneous markers
- Distance culling reduces calculations
- Updates only on location/heading changes

## Future Enhancements

Possible improvements:
- Tap markers for detailed info
- Distance rings on overlay
- Elevation-based vertical positioning
- AR arrow pointing to nearest POI
- Photo mode with POI annotations
- Route drawing to selected POI
- Filter by POI type
- Custom POI additions
