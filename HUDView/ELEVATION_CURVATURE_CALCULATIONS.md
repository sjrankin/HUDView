# Elevation and Earth Curvature Calculations

## Overview
The POI overlay system now accounts for both elevation differences and Earth's curvature when positioning markers on screen, providing a more realistic augmented reality experience.

## Physics & Geometry

### Earth's Curvature

The Earth's surface curves away from the viewer at distance. This effect becomes significant at distances over 5-10 km.

**Curvature Drop Formula:**
```
drop = distance² / (2 × Earth_radius)
```

Where:
- `distance` = horizontal distance to POI (meters)
- `Earth_radius` = 6,371,000 meters (mean radius)

**Examples:**
- At 10 km: drop ≈ 7.8 meters
- At 20 km: drop ≈ 31.4 meters
- At 50 km: drop ≈ 196 meters
- At 100 km: drop ≈ 785 meters

This means a mountain peak 100 km away appears nearly 800 meters "higher" than it would on a flat earth!

### Elevation Angle Calculation

The elevation angle is the vertical angle from the horizontal plane at the user's position to the POI.

**Formula:**
```
angle = atan2(effective_elevation_difference, horizontal_distance)
```

**Effective Elevation Difference:**
```
effective_elevation = (POI_elevation - user_elevation) + curvature_drop
```

The curvature drop is **added** because Earth curves away, making distant objects appear higher than they would on a flat surface.

## Screen Positioning

### Vertical Field of View (FOV)

Most smartphone cameras have:
- **Horizontal FOV**: ~60-70°
- **Vertical FOV**: ~40-50°

We use **40°** vertical FOV (±20° from center) for our calculations.

### Mapping Angle to Screen Position

```
screen_y = screen_center - (elevation_angle / half_vertical_fov) × (screen_height × 0.4)
```

**Coordinate System:**
- Positive angle (looking up) → lower Y value (higher on screen)
- Negative angle (looking down) → higher Y value (lower on screen)
- 0° → center of screen

### Position Range

We use 40% of screen height for the positioning range:
- **+20° elevation**: 20% from top
- **0° elevation**: 50% from top (center)
- **-20° elevation**: 80% from top

This keeps POIs within the viewable area while maintaining proper perspective.

## Real-World Examples

### Example 1: Mount Diablo from San Francisco
- **Distance**: ~40 km
- **User elevation**: 15 m (sea level, SF)
- **Peak elevation**: 1,173 m
- **Curvature drop**: 125 m

```
Effective elevation = (1173 - 15) + 125 = 1,283 m
Angle = atan2(1283, 40000) = 1.84°
Screen position: slightly above center
```

### Example 2: Mount Hamilton from San Jose
- **Distance**: ~25 km
- **User elevation**: 100 m
- **Peak elevation**: 1,283 m
- **Curvature drop**: 49 m

```
Effective elevation = (1283 - 100) + 49 = 1,232 m
Angle = atan2(1232, 25000) = 2.82°
Screen position: above center (more noticeable)
```

### Example 3: City at Same Elevation
- **Distance**: 20 km
- **User elevation**: 50 m
- **POI elevation**: 50 m (same level)
- **Curvature drop**: 31 m

```
Effective elevation = (50 - 50) + 31 = 31 m
Angle = atan2(31, 20000) = 0.09°
Screen position: very slightly above center
```

Even locations at the same elevation appear slightly above the horizon due to Earth's curvature!

### Example 4: Lake Tahoe from Reno
- **Distance**: ~60 km
- **User elevation**: 1,370 m
- **Lake elevation**: 1,897 m (surface)
- **Curvature drop**: 282 m

```
Effective elevation = (1897 - 1370) + 282 = 809 m
Angle = atan2(809, 60000) = 0.77°
Screen position: slightly above center
```

## Code Implementation

### In POIOverlayView

```swift
private func calculateElevationAngle(
    poiElevation: Double?, 
    userElevation: Double?, 
    distance: Double
) -> Double {
    let earthRadius: Double = 6_371_000 // meters
    let userElev = userElevation ?? 0
    let poiElev = poiElevation ?? 0
    
    // Calculate Earth's curvature
    let curvatureDrop = (distance * distance) / (2.0 * earthRadius)
    
    // Effective elevation with curvature
    let effectiveElevationDiff = (poiElev - userElev) + curvatureDrop
    
    // Calculate angle
    let angleRadians = atan2(effectiveElevationDiff, distance)
    return angleRadians * 180.0 / .pi
}
```

### In HUDView

```swift
POIOverlayView(
    visiblePOIs: visiblePOIs,
    userElevation: locationManager.altitude  // Passes user's elevation
)
```

## Visual Effects

### What Users Will See

1. **Mountains and peaks** appear higher on screen (looking up)
2. **Valleys and beaches** appear lower (looking down or at horizon)
3. **Distant landmarks** appear higher due to curvature
4. **Nearby landmarks** appear more centered
5. **Same-elevation locations** appear slightly above horizon

### Distance Effects

- **< 5 km**: Curvature negligible, elevation difference dominant
- **5-20 km**: Curvature starts to matter (~8-31m effect)
- **20-50 km**: Curvature significant (~31-196m effect)
- **> 50 km**: Curvature very significant (>196m effect)

## Accuracy Considerations

### Factors Affecting Accuracy

1. **Atmospheric Refraction**: Light bends slightly, making distant objects appear higher (~0.1-0.2° effect)
2. **GPS Elevation Accuracy**: ±10-50 meters typical
3. **POI Elevation Data**: May vary in accuracy
4. **Camera Tilt**: Assumes phone held level
5. **Device Motion**: Real-time heading changes

### When It Works Best

- Clear weather conditions
- Device held relatively level
- Distances: 1-100 km
- Known POI elevations
- Accurate GPS signal

## Benefits

### Improved AR Experience

1. **Realistic positioning**: Matches what users actually see
2. **Height perception**: Conveys relative heights naturally
3. **Distance cues**: Farther objects appear higher (natural perspective)
4. **Physical accuracy**: Based on real geodesy
5. **Educational**: Shows Earth's curvature effect

### Use Cases

- Mountain peak identification
- Skyline navigation
- Horizon landmark spotting
- Geographic education
- Professional surveying aids

## Future Enhancements

Possible improvements:

1. **Atmospheric refraction correction**
2. **Terrain elevation profiles** (not just POI elevation)
3. **3D topographic visualization**
4. **Dynamic FOV detection** from camera
5. **Phone tilt compensation** using accelerometer
6. **Line-of-sight calculation** (accounting for terrain blocking)
7. **Visibility distance** based on weather/atmosphere

## References

### Formulas Used

- **Earth curvature**: Geometric approximation for distances < 200km
- **Elevation angle**: Standard trigonometric calculation
- **Screen mapping**: Linear interpolation within FOV range

### Constants

- **Earth radius**: 6,371,000 m (mean radius)
- **Vertical FOV**: 40° (typical smartphone camera)
- **Horizontal FOV**: 60° (typical smartphone camera)

## Testing Tips

To verify the calculations are working:

1. **Find a known mountain peak** visible from your location
2. **Check the POI marker position** on screen
3. **Compare to actual visual position** of the peak
4. **Note elevation in info panel** at bottom
5. **Test at various distances** (near and far)

The marker should align closely with the actual landmark when the phone is held level!
