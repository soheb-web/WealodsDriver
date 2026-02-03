import 'package:flutter/material.dart';

class OnbordingPolicyPage extends StatelessWidget {
  const OnbordingPolicyPage({super.key});

  static const Color themeColor = Color(0xFF006970);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "Driver Onboarding Policy",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 20),

            _section(
              title: "1. Introduction",
              content:
                  "This Driver Onboarding Policy outlines the requirements and process for individuals who wish to join the Weloads platform as Driver Partners.\n\n"
                  "Weloads operates strictly as an aggregator, enabling customers to connect with independent third-party drivers. Driver Partners operate on a voluntary, flexible, non-employment basis.",
            ),

            _section(
              title: "2. Eligibility Criteria",
              content:
                  "To become a Driver Partner on Weloads, you must meet the following conditions:\n\n"
                  "2.1 Age Requirement:\nMinimum age: 18 years\n\n"
                  "2.2 Documents Required:\n\n"
                  "Identity & Personal Documents:\n"
                  "• Aadhaar Card / PAN Card\n"
                  "• Recent passport-size photo\n\n"
                  "Driving & Vehicle Documents:\n"
                  "• Valid Driving License\n"
                  "• Vehicle Registration Certificate (RC)\n"
                  "• Insurance Certificate\n"
                  "• PUCC (Pollution Certificate)\n\n"
                  "Bank Details:\n"
                  "• Account holder name\n"
                  "• Account number\n"
                  "• IFSC code\n"
                  "(For receiving settlements)",
            ),

            _section(
              title: "3. Verification Process",
              content:
                  "Weloads completes the following checks:\n\n"
                  "• Document Screening (authenticity & expiry)\n"
                  "• KYC Verification\n"
                  "• Vehicle Eligibility Check\n"
                  "• Background Check (if required)\n"
                  "• Mobile Number Verification (OTP)\n"
                  "• Face Match (optional)\n\n"
                  "If any document is found fake or invalid, onboarding will be rejected immediately.",
            ),

            _section(
              title: "4. Activation on Platform",
              content:
                  "After verification, the Driver Partner must:\n\n"
                  "• Agree to Driver Terms & Conditions\n"
                  "• Agree to Privacy Policy\n"
                  "• Complete mandatory profile fields\n"
                  "• Upload live photo/selfie\n"
                  "• Enable GPS/location access at all times\n\n"
                  "Upon completion, the driver profile is activated and visible for bookings.",
            ),

            _section(
              title: "5. Vehicle Requirements",
              content:
                  "All vehicles used on Weloads must:\n\n"
                  "• Be in good working condition\n"
                  "• Have valid RC, insurance, DL, and pollution certificate\n"
                  "• Be clean, safe, and suitable for transporting goods\n\n"
                  "Weloads may deactivate vehicles that fail quality standards.",
            ),

            _section(
              title: "6. Driver Responsibilities",
              content:
                  "6.1 Operate Responsibly:\n"
                  "• Follow traffic rules\n"
                  "• Avoid rash driving\n"
                  "• Deliver goods safely and on time\n\n"
                  "6.2 Maintain Professional Behaviour:\n"
                  "• No abuse or harassment\n"
                  "• No intoxication\n"
                  "• Polite communication\n\n"
                  "6.3 Compliance:\n"
                  "• Keep documents updated\n"
                  "• Provide accurate information\n"
                  "• Use the app only for legitimate deliveries",
            ),

            _section(
              title: "7. Device & Technical Requirements",
              content:
                  "• Smartphone with stable internet\n"
                  "• Updated Weloads Driver App\n"
                  "• GPS/location must remain ON during active orders\n\n"
                  "Disabling GPS may result in temporary suspension.",
            ),

            _section(
              title: "8. Training & Guidelines",
              content:
                  "Drivers may receive:\n\n"
                  "• App usage training\n"
                  "• Safety instructions\n"
                  "• Loading/unloading guidance\n"
                  "• Customer interaction etiquette\n\n"
                  "Training may be provided online or in-app.",
            ),

            _section(
              title: "9. Earnings & Payments",
              content:
                  "9.1 Commission:\n"
                  "Driver earnings are subject to platform commissions visible in-app.\n\n"
                  "9.2 Settlement:\n"
                  "Payments are settled to the driver’s bank account as per schedule.\n"
                  "Weloads is not responsible for delays due to incorrect bank details.",
            ),

            _section(
              title: "10. Suspension & Deactivation",
              content:
                  "A driver may be suspended or removed for:\n\n"
                  "• Fake documents\n"
                  "• Customer complaints\n"
                  "• Fraud or misuse\n"
                  "• Repeated cancellations\n"
                  "• Policy violations\n"
                  "• Theft or unlawful activities\n\n"
                  "Suspension may be temporary or permanent.",
            ),

            _section(
              title: "11. Aggregator Disclaimer",
              content:
                  "Weloads is not an employer of Driver Partners.\n\n"
                  "Drivers are responsible for:\n"
                  "• Vehicle & fuel costs\n"
                  "• Maintenance & insurance\n"
                  "• Compliance with local laws\n\n"
                  "Weloads only facilitates connections between customers and drivers.",
            ),

            _section(
              title: "12. Policy Updates & Disputes",
              content:
                  "Weloads may update this policy from time to time.\n"
                  "Updates will be communicated via the app or website.\n\n"
                  "Any dispute shall be handled as per the Weloads Driver Partner Terms & Conditions.\n"
                  "Exclusive jurisdiction: Mumbai, Maharashtra.",
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                "© 2026 Weloads. All rights reserved.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weloads – Driver Onboarding Policy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Effective Date: 1 November 2025\n\n"
            "This policy explains onboarding rules and requirements for Driver Partners.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
