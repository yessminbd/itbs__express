class UnboardingContent {
  String image;
  String title;
  String description;

  UnboardingContent({
    required this.description,
    required this.image,
    required this.title,
  });
}

List<UnboardingContent> contents = [
  UnboardingContent(
    image: "images/screen1.png",
    title: "Check notre menu",
    description:
        "Toutes tes options fast-food préférées sont là,\nprêtes à être choppées sur ITBS Express !",
  ),
  UnboardingContent(
    image: "images/screen2.png",
    title: "Pick rapide",
    description:
        "Choisis ce que tu veux et prépare-toi à te régaler\nen un clin d'œil !",
  ),
];
