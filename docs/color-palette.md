# Chainy Color Palette

## Primary Palette
Chainy uses a modern black-based color scheme with white text and blue accents:

### Core Colors
- **Black**: `#000000` - Primary app background
- **Card Gray**: `#1C1C1E` - Habit cards, secondary surfaces
- **White**: `#FFFFFF` - Primary text, high contrast elements
- **Blue**: `#007AFF` - Progress bars, active elements, CTAs
- **Orange**: `#fca311` - Streak icons, success indicators
- **Light Gray**: `#2C2C2E` - Inactive progress segments, disabled states
- **Text Gray**: `#8E8E93` - Secondary text, day labels
- **Border Gray**: `#3A3A3C` - Dividers, borders

### Flutter Implementation
```dart
class ChainyColors {
  static const Color black = Color(0xFF000000);
  static const Color cardGray = Color(0xFF1C1C1E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF007AFF);
  static const Color orange = Color(0xFFfca311);
  static const Color lightGray = Color(0xFF2C2C2E);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color borderGray = Color(0xFF3A3A3C);
}
```

### Usage Guidelines
- **Black (#000000)**: Primary app background
- **Card Gray (#1C1C1E)**: Habit cards, secondary surfaces
- **White (#FFFFFF)**: Primary text, habit names, main content
- **Blue (#007AFF)**: Progress bars, active day indicators, interactive elements
- **Orange (#fca311)**: Streak flame icons, success indicators
- **Light Gray (#2C2C2E)**: Inactive progress segments, disabled states
- **Text Gray (#8E8E93)**: Secondary text, day labels, subtle information
- **Border Gray (#3A3A3C)**: Dividers, borders, inactive day circles

### Accessibility
- Ensure sufficient contrast ratios (4.5:1 for normal text, 3:1 for large text)
- Test with high contrast mode
- Consider dark mode variations for future implementation

## Source
- **Design Reference**: Modern black-based theme with blue accents and orange highlights
- **Colors**: #000000, #1C1C1E, #FFFFFF, #007AFF, #fca311, #2C2C2E, #8E8E93, #3A3A3C
- **PRD Reference**: `.taskmaster/docs/chainy-prd.txt`
