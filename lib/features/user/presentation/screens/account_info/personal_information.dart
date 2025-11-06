import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
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
      appBar: AppBar(title: Text("Personal Information"), centerTitle: true),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final cubit = context.read<UserBloc>();
          if (userState is UserLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      spacing: 24,
                      children: [
                        TextInputField(
                          label: "Name",
                          suffix: "",
                          value: userState.user!.name,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                        ),
                        DropdownButtonFormField<Role>(
                          elevation: 2,
                          alignment: AlignmentDirectional.topCenter,
                          initialValue: userState.role,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            label: Text("Role"),
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGray,
                            ),
                          ),
                          items: [
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
                              // cubit.add(FinalizeRoleSelection(v));
                            }
                          },
                        ),
                        TextInputField(
                          label: "Email",
                          suffix: "",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextInputField(
                          label: "Address",
                          suffix: "",
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
