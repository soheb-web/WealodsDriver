import 'package:flutter/material.dart';

class TermsConditionPage extends StatelessWidget {
  const TermsConditionPage({super.key});

  static const Color themeColor = Color(0xFF006970);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "Terms & Conditions",
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
              title: "1. Role of Weloads",
              content:
                  "1.1 Weloads is only a technology aggregator providing a digital platform for connecting customers with independent driver partners.\n\n"
                  "1.2 Weloads does NOT own, operate, control, or manage any vehicles.\n\n"
                  "1.3 Weloads is NOT responsible for the acts, conduct, behaviour, or performance of the Driver.\n\n"
                  "1.4 Driver performs all services as an independent third-party service provider, not as an employee or agent of Weloads.",
            ),

            _section(
              title: "2. Driver Eligibility",
              content:
                  "The Driver confirms that:\n\n"
                  "2.1 He/she holds a valid driving licence.\n\n"
                  "2.2 The vehicle has valid registration, insurance, fitness certificate, and permits as required by law.\n\n"
                  "2.3 The Driver has no disqualifications under Motor Vehicle Laws.\n\n"
                  "2.4 All documents submitted to the Platform are genuine and up to date.",
            ),

            _section(
              title: "3. Using the Platform",
              content:
                  "3.1 Driver must keep their account details secure and shall be responsible for all activity under their account.\n\n"
                  "3.2 Weloads may verify the Driver’s documents anytime.\n\n"
                  "3.3 Weloads may suspend or terminate Driver access for any misuse, fraud, or violation of law.",
            ),

            _section(
              title: "4. Acceptance of Trips",
              content:
                  "4.1 Driver is free to accept or reject any booking request.\n\n"
                  "4.2 Once a trip is accepted, the Driver must complete it professionally and safely.\n\n"
                  "4.3 Cancelling trips without valid reasons may result in penalties, lower ratings, or temporary suspension.",
            ),

            _section(
              title: "5. Zero Liability of Weloads",
              content:
                  "5.1 Weloads’ role is limited to arranging a vehicle through the Platform.\n\n"
                  "5.2 Weloads does not guarantee earnings, number of trips, or profits.\n\n"
                  "5.3 Weloads is not liable for accidents, damage, theft, loss of goods, delays, misconduct of driver or customer, or any disputes arising during the trip.\n\n"
                  "5.4 All liabilities relating to trips, vehicle condition, or customer interaction remain only with the Driver.",
            ),

            _section(
              title: "6. Vehicle Condition & Safety",
              content:
                  "6.1 Driver must ensure the vehicle is clean, safe, and mechanically fit.\n\n"
                  "6.2 Driver must follow all traffic laws, safety guidelines, and local regulations.\n\n"
                  "6.3 Driver is solely responsible for any fines, penalties, challans, or legal actions.",
            ),

            _section(
              title: "7. Payments & Settlements",
              content:
                  "7.1 Weloads collects payments from customers on behalf of the Driver.\n\n"
                  "7.2 Platform fees, commissions, or charges may be deducted before settlement.\n\n"
                  "7.3 Settlement timelines may vary depending on banks/UPI/payment partners.\n\n"
                  "7.4 Driver must comply with GST or tax requirements, if applicable.",
            ),

            _section(
              title: "8. Ratings & Behaviour",
              content:
                  "8.1 Drivers must behave respectfully with customers and Weloads staff.\n\n"
                  "8.2 Abusive behaviour, harassment, misconduct, intoxication, or unsafe driving may lead to permanent deactivation.\n\n"
                  "8.3 Driver ratings affect trip allocation and incentives.",
            ),

            _section(
              title: "9. Goods Handling",
              content:
                  "9.1 Driver is responsible for safe loading and unloading of goods.\n\n"
                  "9.2 Driver must check packaging before accepting the goods.\n\n"
                  "9.3 Driver must refuse prohibited or illegal items (alcohol, drugs, explosives, etc.).",
            ),

            _section(
              title: "10. No Insurance by Weloads",
              content:
                  "10.1 Weloads does not provide any insurance for vehicles, drivers, or goods.\n\n"
                  "10.2 Driver must rely on their own insurance policies (vehicle or personal).",
            ),

            _section(
              title: "11. Platform Fees & Changes",
              content:
                  "11.1 Weloads may revise platform charges, commission, penalties, cancellation fees, or settlements at any time.\n\n"
                  "11.2 Continued use of the Platform means acceptance of updated terms.",
            ),

            _section(
              title: "12. Data Usage",
              content:
                  "12.1 Weloads may collect and use Driver data (location, trip data, KYC documents) for safety, analytics, and platform improvement.\n\n"
                  "12.2 Data may be shared with law enforcement when legally required.",
            ),

            _section(
              title: "13. Suspension, Indemnification & Confidentiality",
              content:
                  "Weloads may suspend or permanently deactivate a Driver for fraud, safety violations, customer complaints, repeated cancellations, illegal goods, or misuse of the Platform.\n\n"
                  "Indemnification (Kshatipurti): The Driver agrees to compensate Weloads for any losses, legal claims, or damages caused due to Driver’s actions.\n\n"
                  "Confidentiality (Gopneeyata): Driver must not disclose Weloads’ confidential information including pricing, customer data, or platform details.",
            ),

            _section(
              title: "14. Dispute Resolution",
              content:
                  "14.1 Disputes shall be resolved via email or in-app support.\n\n"
                  "14.2 If unresolved, disputes shall be referred to arbitration under the Arbitration & Conciliation Act, 1996.\n\n"
                  "14.3 Exclusive jurisdiction: Mumbai, Maharashtra.",
            ),

            _section(
              title: "15. Acceptance",
              content:
                  "By continuing to use the Weloads Driver App, you acknowledge and accept all terms mentioned above.",
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
            "Weloads – Driver Partner Terms & Conditions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Effective Date: 01 December 2025\n\nPlease read these terms carefully before using the Weloads Driver App.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
