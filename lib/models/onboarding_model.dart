class OnboardingModel {
  final String title;
  final String titleHighlight;
  final String description;
  final String imagePath;

  OnboardingModel({
    required this.title,
    this.titleHighlight = '',
    required this.description,
    required this.imagePath,
  });
}

List<OnboardingModel> onboardingData = [
  OnboardingModel(
    title: "Secure ",
    titleHighlight: "NGN Wallet",
    description: "Experience seamless deposits and withdrawals. Your gateway to crypto starts with a fully protected Naira wallet.",
    imagePath: "assets/images/onboarding_main_1.png",
  ),
  OnboardingModel(
    title: "Spot & P2P Trading",
    description: "Access global markets instantly with Spot trading or buy and sell crypto directly with cash using our secure P2P platform tailored for Nigeria.",
    imagePath: "assets/images/onboarding_main_2.png",
  ),
  OnboardingModel(
    title: "Swift KYC Verification",
    description: "Safety first. Verify your identity instantly to start trading securely. Our streamlined process gets you onboarded in minutes.",
    imagePath: "assets/images/onboarding_main_3.png",
  ),
];
