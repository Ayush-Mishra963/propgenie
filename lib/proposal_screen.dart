import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'saved_proposals_screen.dart';
import 'auth_screen.dart';
import 'openai_service.dart';
import 'usage_service.dart';
import 'premium_upgrade_screen.dart';
import 'help_screen.dart';


const Color kPrimaryPurple = Color(0xFFEAE6FA);
const Color kAccentCircle = Color(0xFFBDADEA);

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _roleController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _generatedProposal;
  bool _isLoading = false;
  bool _isPressed = false;

  int _remainingAttempts = 5;
  bool _isPremium = false;
  bool _isLoadingAttempts = true;

  @override
  void initState() {
    super.initState();
    _fetchUserUsageStatus();
  }

  Future<void> _fetchUserUsageStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _remainingAttempts = 0;
        _isPremium = false;
        _isLoadingAttempts = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    final attempts = (data?['postSignupAttempts'] ?? 0) as int;
    final premium = data?['premium'] ?? false;

    setState(() {
      _isPremium = premium;
      _remainingAttempts = premium ? -1 : 5 - attempts;
      _isLoadingAttempts = false;
    });
  }

  Future<void> _generateProposal() async {
    final name = _nameController.text.trim();
    final client = _clientController.text.trim();
    final role = _roleController.text.trim();
    final exp = _experienceController.text.trim();

    if (name.isEmpty || client.isEmpty || role.isEmpty || exp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedProposal = null;
    });

    final allowed = await UsageService.isAllowedToGenerate();

    if (!allowed) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Usage limit reached. Upgrade to continue."),
          action: SnackBarAction(
            label: "Upgrade",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen()),
              );
            },
          ),
        ),
      );

      return;
    }

    try {
      final proposal = await OpenAIService.generateProposal(
        name: name,
        client: client,
        role: role,
        experience: exp,
      );

      setState(() {
        _isLoading = false;
      });

      // Only save and refresh usage if the proposal is valid
      if (proposal != null && 
          proposal.isNotEmpty && 
          !proposal.contains("Failed to generate proposal")) {
        setState(() => _generatedProposal = proposal);
        await _saveProposalToFirestore(proposal);
        await _fetchUserUsageStatus(); // Only deduct if success
      } else {
        setState(() => _generatedProposal = "Failed to generate proposal. Please try again.");
      }

          } catch (e) {
            setState(() {
              _generatedProposal = "Error generating proposal. Try again.";
              _isLoading = false;
            });
          }
        }

  Future<void> _saveProposalToFirestore(String proposal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_proposals')
        .add({
      'proposal': proposal,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Proposal saved to your library.")),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: const Text("Proposal Generator AI"),
        actions: [
          IconButton(
      icon: Icon(Icons.help_outline),
      tooltip: 'Help',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpScreen()),
        );
      },
    ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFEAE6FA)),
          Positioned(
            top: -60,
            left: -30,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: kAccentCircle.withOpacity(0.25),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: CircleAvatar(
              radius: 130,
              backgroundColor: kAccentCircle.withOpacity(0.2),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _styledTextField(_nameController, "Your Name"),
                _styledTextField(_clientController, "Client Name"),
                _styledTextField(_roleController, "Job Role"),
                _styledTextField(_experienceController, "Your Experience (in years)", keyboardType: TextInputType.number),

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : AnimatedScale(
                        scale: _isPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() => _isPressed = true);
                            await _generateProposal();
                            setState(() => _isPressed = false);
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text("Generate Proposal"),
                          style: _buttonStyle(),
                        ),
                      ),

                const SizedBox(height: 8),

                if (!_isLoadingAttempts)
                  Text(
                    _isPremium
                        ? "🔓 You have unlimited access."
                        : "🟣 You have $_remainingAttempts free proposals remaining.",
                    style: const TextStyle(color: Colors.black87),
                  ),

                const SizedBox(height: 24),

                if (_generatedProposal != null) ...[
                  const Text(
                    "Generated Proposal:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(_generatedProposal!),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedProposal!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard!")),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy to Clipboard"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                if (!_isPremium)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen()),
                      );
                    },
                    child: const Text("Upgrade to Premium →"),
                  ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SavedProposalsScreen()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("View Saved Proposals"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
} 