/// Utility class for mapping species names to local image assets
class SpeciesImageMapper {
  /// Get the local asset path for a species based on its name
  static String getImagePath(String speciesName) {
    switch (speciesName.toLowerCase()) {
      case 'grey shrimp':
      case 'gray shrimp':
      case 'crevette grise':
        return 'assets/shrimp-species/grey-shrimp.png';
      case 'pink shrimp':
      case 'crevette rose':
        return 'assets/shrimp-species/pink-shrimp.png';
      case 'tiger shrimp':
      case 'crevette tiger':
        return 'assets/shrimp-species/tiger-shrimp.png';
      case 'prawns':
      case 'panaeus monodon':
        return 'assets/shrimp-species/prawn.png';
      default:
        return 'assets/images/shrimp.jpg'; // fallback
    }
  }
}
