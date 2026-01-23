import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/providers/profile_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/core/widgets/text_input_field.dart';

class PersonalInformation extends ConsumerStatefulWidget {
  const PersonalInformation({super.key});

  @override
  ConsumerState<PersonalInformation> createState() =>
      _PersonalInformationState();
}

class _PersonalInformationState extends ConsumerState<PersonalInformation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _hasInitializedControllers = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use myProfileProvider for full profile data from API
    final profileAsync = ref.watch(myProfileProvider);
    // Use myStatisticsProvider for statistics from API
    final statisticsAsync = ref.watch(myStatisticsProvider);
    // Keep currentUserProvider for role info
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Personal Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: profileAsync.when(
        data: (profile) {
          // Initialize controllers once with profile data
          if (!_hasInitializedControllers) {
            final displayName =
                '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
            _nameController.text = displayName.isNotEmpty
                ? displayName
                : (profile.username ?? '');
            _emailController.text = profile.email ?? '';
            _addressController.text = profile.address ?? '';
            _phoneController.text = profile.phoneNumber ?? profile.phone ?? '';
            _hasInitializedControllers = true;
          }

          // Get current role from userAsync
          final currentRole = userAsync.maybeWhen(
            data: (user) => user?.currentRole ?? UserRole.buyer,
            orElse: () => UserRole.buyer,
          );

          return RefreshIndicator(
            onRefresh: () async {
              _hasInitializedControllers = false;
              ref.invalidate(myProfileProvider);
              ref.invalidate(myStatisticsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
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
                          value: _nameController.text,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<UserRole>(
                          initialValue: currentRole,
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
                              value: UserRole.fisher,
                              child: Text("Fisher"),
                            ),
                            DropdownMenuItem(
                              value: UserRole.buyer,
                              child: Text("Buyer"),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              // TODO: update user role
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        TextInputField(
                          label: "Email",
                          suffix: "",
                          value: _emailController.text,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        TextInputField(
                          label: "Phone",
                          suffix: "",
                          value: _phoneController.text,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        TextInputField(
                          label: "Address",
                          suffix: "",
                          value: _addressController.text,
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // === Section 2: Statistics ===
                  SectionHeader("Statistics"),
                  const SizedBox(height: 16),

                  statisticsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                "Active Products",
                                stats.activeProducts.toString(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _infoCard(
                                "Total Catches",
                                stats.totalCatches.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                "Completed Orders",
                                stats.completedOrders.toString(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _infoCard(
                                "Total Sales",
                                stats.totalSales.toString(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                "Average Rating",
                                stats.averageRating.toStringAsFixed(1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _infoCard(
                                "Total Reviews",
                                stats.totalReviews.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _infoCard(
                          "Turnover (${stats.period})",
                          "${stats.turnover} ${stats.currency}",
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load statistics: $error',
                        style: const TextStyle(color: AppColors.fail500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load profile: $error',
                  style: const TextStyle(color: AppColors.fail500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(myProfileProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
