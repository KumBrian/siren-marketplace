import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/core/widgets/text_input_field.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Personal Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is! UserLoaded) return const SizedBox();

          final user = userState.user!;
          final role = userState.role;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === Section 1: Personal Info ===
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextInputField(
                        label: "Name",
                        suffix: "",
                        value: user.name,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<Role>(
                        initialValue: role,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: "Role",
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGray,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Role.fisher,
                            child: Text("Fisher"),
                          ),
                          DropdownMenuItem(
                            value: Role.buyer,
                            child: Text("Buyer"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            // context.read<UserBloc>().add(FinalizeRoleSelection(v));
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      TextInputField(
                        label: "Email",
                        suffix: "",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      TextInputField(
                        label: "Address",
                        suffix: "",
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // === Section 2: Order History ===
                SectionHeader("Order History"),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _infoCard("Offers Received", "25")),
                    const SizedBox(width: 16),
                    Expanded(child: _infoCard("Total Catch", "120")),
                  ],
                ),

                const SizedBox(height: 16),

                _infoCard("Last Order", "2 Weeks Ago"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
